import Foundation
import SwiftUI

@MainActor
@Observable
final class MenuViewModel {

    enum Route: Identifiable {
        case createDish
        case settings
        case editDish(Dish)

        var id: String {
            switch self {
            case .createDish:
                "createDish"
            case .settings:
                "settings"
            case .editDish(let dish):
                "editDish_\(dish.id)"
            }
        }
    }

    // MARK: - State

    var dishesState: Loading<[Dish]> = .loading
    var selectedDishes: Set<Int> = []
    var activeRoute: Route?

    var selectedTab = 0

    var currentChef: String?

    var selectedDate: Date = Date()

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var autoRefreshTask: Task<Void, Never>?
    private var isSilentReloadInFlight = false
    private var needsSilentReload = false
    private var queuedSilentReloadRequests = 0
    private let feedAnimation: Animation = .easeInOut(duration: 0.25)

    private var favoriteDebouncers: [Int: TaskDebouncer] = [:]

    var role: UserRole = .user {
        didSet {
            UserDefaults.standard.set(role.rawValue, forKey: UserDefaultsKeys.userRole)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasRoleSelected)
        }
    }

    private let dishService: DishesServiceProtocol
    private let chefService: ChefServiceProtocol

    // MARK: - Computed

    var chefDisplayName: String {
        guard let name = currentChef, !name.isEmpty else { return "не назначен" }
        return name
    }

    var groupedDishes: [DishCategory: [Dish]] {
        Dictionary(grouping: dishesState.value ?? [], by: { $0.category })
    }

    var favoriteDishes: [Dish] {
        (dishesState.value ?? []).filter { $0.favourite }
    }

    // MARK: - Init

    init(
        dishService: DishesServiceProtocol = DishesService(),
        chefService: ChefServiceProtocol = ChefService()
    ) {
        self.dishService = dishService
        self.chefService = chefService

        self.currentChef = UserDefaults.standard.string(forKey: "currentChef")

        if let saved = UserDefaults.standard.string(forKey: UserDefaultsKeys.userRole),
           let role = UserRole(rawValue: saved) {
            self.role = role
        }

        setupSegmentedAppearance()
        setupCleanupObserver()
    }

    // MARK: - Appearance

    private func setupSegmentedAppearance() {
        let appearance = UISegmentedControl.appearance()

        appearance.selectedSegmentTintColor = MenuColors.uiPaper

        appearance.setTitleTextAttributes([
            .font: Typography.segmentedSelected,
            .foregroundColor: MenuColors.uiText
        ], for: .selected)

        appearance.setTitleTextAttributes([
            .font: Typography.segmentedNormal,
            .foregroundColor: MenuColors.uiSecondary
        ], for: .normal)
    }

    // MARK: - Auto refresh (каждые 5 сек, только для сегодня)

    func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(5))
                } catch {
                    break
                }
                guard !Task.isCancelled, isToday else { continue }
                await silentReloadAll()
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    // MARK: - First load (с индикатором)

    func loadAllDishes() async {
        dishesState = .loading
        do {
            let response = try await dishService.getDishes(date: formattedDate(selectedDate))
            withAnimation(feedAnimation) {
                dishesState = .loaded(response.data)
            }
        } catch {
            Logger.log(level: .error(error), "Error loading dishes")
            withAnimation(feedAnimation) {
                dishesState = .loaded([])
            }
        }
    }

    func loadCurrentChef() async {
        do {
            let chef = try await chefService.current()
            withAnimation(feedAnimation) {
                currentChef = chef.name
            }
            UserDefaults.standard.set(chef.name, forKey: "currentChef")
        } catch {
            Logger.log(level: .error(error), "Error loading chef")
        }
    }

    // MARK: - Silent reload

    func silentReloadAll() async {
        if isSilentReloadInFlight {
            queuedSilentReloadRequests += 1
            needsSilentReload = true
            return
        }

        repeat {
            isSilentReloadInFlight = true
            needsSilentReload = false

            async let dishesTask = dishService.getDishes(date: formattedDate(selectedDate))
            async let chefTask = chefService.current()

            do {
                let response = try await dishesTask
                withAnimation(feedAnimation) {
                    dishesState = .loaded(response.data)
                }
            } catch {
                Logger.log(level: .error(error), "Silent reload dishes error")
            }

            do {
                let chef = try await chefTask
                if currentChef != chef.name {
                    withAnimation(feedAnimation) {
                        currentChef = chef.name
                    }
                    UserDefaults.standard.set(chef.name, forKey: "currentChef")
                }
            } catch {
                Logger.log(level: .error(error), "Silent reload chef error")
            }

            isSilentReloadInFlight = false

            if needsSilentReload {
                queuedSilentReloadRequests = 0
            }
        } while needsSilentReload

        queuedSilentReloadRequests = 0
    }

    // MARK: - Public Methods

    func toggleFavorite(dishId: Int) {
        guard role.permissions.canToggleFavorite,
              case .loaded(var dishes) = dishesState,
              let index = dishes.firstIndex(where: { $0.id == dishId }) else { return }

        let newValue = !dishes[index].favourite
        dishes[index].favourite = newValue
        withAnimation(feedAnimation) {
            dishesState = .loaded(dishes)
        }

        let d = debouncer(for: dishId)
        Task {
            await d.debounce { [weak self] in
                await self?.sendToggleFavoriteRequest(dishId: dishId, newValue: newValue)
            }
        }
    }

    func deleteDish(dishId: Int) {
        Task { await deleteDishRequest(dishId: dishId) }
    }

    func deleteAllDishes() {
        Task { await deleteAllDishesRequest() }
    }

    func applySecret(_ secret: String) {
        self.role = roleFromSecret(secret)
    }

    // MARK: - Nav Actions

    func openCreateDish() {
        guard role.permissions.canCreateDish else { return }
        activeRoute = .createDish
    }

    func openSettings() {
        guard role.permissions.canChangeChef else { return }
        activeRoute = .settings
    }

    func openEditDish(_ dish: Dish) {
        guard role.permissions.canEditDish else { return }
        activeRoute = .editDish(dish)
    }

    // MARK: - Private Helpers

    private func debouncer(for dishId: Int) -> TaskDebouncer {
        if let existing = favoriteDebouncers[dishId] { return existing }
        let new = TaskDebouncer()
        favoriteDebouncers[dishId] = new
        return new
    }

    private func formattedDate(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02dT00:00:00Z", c.year!, c.month!, c.day!)
    }

    private func setupCleanupObserver() {
        NotificationCenter.default.addObserver(
            forName: .dailyCleanupDidFinish,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task {
                withAnimation(self.feedAnimation) {
                    self.dishesState = .loaded([])
                    self.currentChef = nil
                }
                await self.silentReloadAll()
            }
        }
    }

    // MARK: - Private Requests

    private func sendToggleFavoriteRequest(dishId: Int, newValue: Bool) async {
        do {
            if newValue {
                try await dishService.mark(request: MarkDishRequest(ids: [dishId]))
            } else {
                try await dishService.unmark(request: UnMarkDishRequest(ids: [dishId]))
            }
        } catch {
            Logger.log(level: .error(error), "Error toggling favourite")
            if case .loaded(var dishes) = dishesState,
               let index = dishes.firstIndex(where: { $0.id == dishId }) {
                dishes[index].favourite = !newValue
                withAnimation(feedAnimation) {
                    dishesState = .loaded(dishes)
                }
            }
        }
        await silentReloadAll()
    }

    private func deleteDishRequest(dishId: Int) async {
        guard role.permissions.canDeleteDish else { return }
        do {
            try await dishService.delete(request: DeleteDishRequest(id: dishId))
            if case .loaded(var dishes) = dishesState {
                dishes.removeAll { $0.id == dishId }
                withAnimation(feedAnimation) {
                    dishesState = .loaded(dishes)
                }
            }
        } catch {
            Logger.log(level: .error(error), "Error deleting dish")
        }
        await silentReloadAll()
    }

    private func deleteAllDishesRequest() async {
        guard role.permissions.canDeleteDish else { return }
        do {
            try await dishService.deleteAll()
            withAnimation(feedAnimation) {
                dishesState = .loaded([])
            }
        } catch {
            Logger.log(level: .error(error), "Error deleting all dishes")
        }
        await silentReloadAll()
    }

}
