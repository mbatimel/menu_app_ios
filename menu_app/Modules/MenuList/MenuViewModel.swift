import Foundation
import SwiftUI

@MainActor
@Observable
final class MenuViewModel {

    // MARK: - State

    var dishes: [Dish] = []
    var selectedDishes: Set<Int> = []
    var editingDish: Dish?

    var selectedTab = 0
    var showingCreateDish = false
    var showingSettings = false

    /// Используется ТОЛЬКО при первом входе
    var isLoading = false
    var errorMessage: String?

    var currentChef: String?

    private var autoRefreshTask: Task<Void, Never>?

    var role: UserRole = .user {
        didSet {
            UserDefaults.standard.set(role.rawValue, forKey: "userRole")
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasRoleSelected)
        }
    }

    private let dishService: DishesServiceProtocol
    private let chefService: ChefServiceProtocol

    // MARK: - Computed

    var groupedDishes: [DishCategory: [Dish]] {
        Dictionary(grouping: dishes, by: { $0.category })
    }

    var favoriteDishes: [Dish] {
        dishes.filter { $0.favourite }
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

        appearance.selectedSegmentTintColor = UIColor(MenuColors.paper)

        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor(MenuColors.text)
        ], for: .selected)

        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(MenuColors.secondary)
        ], for: .normal)
    }

    // MARK: - Auto refresh (каждые 5 сек, ТИХО)

    func startAutoRefresh() {
        stopAutoRefresh()

        autoRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
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
        isLoading = true
        errorMessage = nil

        let result = await dishService.getDishes()
        if case .success(let response) = result {
            dishes = response.data
        }

        isLoading = false
    }

    func loadCurrentChef() async {
        let result = await chefService.current()
        if case .success(let chef) = result {
            currentChef = chef.name
            UserDefaults.standard.set(chef.name, forKey: "currentChef")
        }
    }

    // MARK: - Silent reload (блюда + повар)

    func silentReloadAll() async {
        async let dishesTask = dishService.getDishes()
        async let chefTask = chefService.current()

        let dishesResult = await dishesTask
        let chefResult = await chefTask

        if case .success(let response) = dishesResult {
            dishes = response.data
        }

        if case .success(let chef) = chefResult {
            if currentChef != chef.name {
                currentChef = chef.name
                UserDefaults.standard.set(chef.name, forKey: "currentChef")
            }
        }
    }

    // MARK: - Actions

    func toggleFavorite(dishId: Int) async {
        guard role.permissions.canToggleFavorite,
              let index = dishes.firstIndex(where: { $0.id == dishId }) else { return }

        let newValue = !dishes[index].favourite
        dishes[index].favourite = newValue

        let result = newValue
            ? await dishService.mark(request: MarkDishRequest(ids: [dishId]))
            : await dishService.unmark(request: UnMarkDishRequest(ids: [dishId]))

        if case .networkError = result {
            dishes[index].favourite.toggle()
        }

        await silentReloadAll()
    }

    func deleteDish(id: Int) async {
        guard role.permissions.canDeleteDish else { return }

        let result = await dishService.delete(request: DeleteDishRequest(id: id))
        if case .success = result {
            dishes.removeAll { $0.id == id }
        }

        await silentReloadAll()
    }

    func deleteAllDishes() async {
        guard role.permissions.canDeleteDish else { return }

        let result = await dishService.deleteAll()
        if case .success = result {
            dishes = []
        }

        await silentReloadAll()
    }

    func updateDish(id: Int, newName: String, newCategory: DishCategory) async {
        guard role.permissions.canEditDish else { return }

        let request = UpdateDishRequest(
            id: id,
            text: newName,
            category: newCategory
        )

        let result = await dishService.updateDish(request: request)
        if case .success = result,
           let index = dishes.firstIndex(where: { $0.id == id }) {
            dishes[index].name = newName
            dishes[index].category = newCategory
        }
    }

    func applySecret(_ secret: String) {
        self.role = roleFromSecret(secret)
    }
    
    private func setupCleanupObserver() {
        NotificationCenter.default.addObserver(
            forName: .dailyCleanupDidFinish,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            Task {
                self.dishes = []
                self.currentChef = nil
                await self.silentReloadAll()
            }
        }
    }

}
