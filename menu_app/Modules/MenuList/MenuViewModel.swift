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

    var dishes: [Dish] = []
    var selectedDishes: Set<Int> = []
    var activeRoute: Route?

    var selectedTab = 0

    /// Используется ТОЛЬКО при первом входе
    var isLoading = false
    var errorMessage: String?

    var currentChef: String?

    private var autoRefreshTask: Task<Void, Never>?
    private var isSilentReloadInFlight = false
    private var needsSilentReload = false
    private var queuedSilentReloadRequests = 0
    private let feedAnimation: Animation = .easeInOut(duration: 0.25)

    var role: UserRole = .user {
        didSet {
            UserDefaults.standard.set(role.rawValue, forKey: UserDefaultsKeys.userRole)
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

    // MARK: - Auto refresh (каждые 5 сек, ТИХО)

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

                if Task.isCancelled {
                    break
                }

                await silentReloadAll(source: "auto-refresh-timer")
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
            withAnimation(feedAnimation) {
                dishes = response.data
            }
        }

        isLoading = false
    }

    func loadCurrentChef() async {
        let result = await chefService.current()
        if case .success(let chef) = result {
            withAnimation(feedAnimation) {
                currentChef = chef.name
            }
            UserDefaults.standard.set(chef.name, forKey: "currentChef")
        }
    }

    // MARK: - Silent reload (блюда + повар)

    func silentReloadAll(source: String = "unknown") async {
        if isSilentReloadInFlight {
            queuedSilentReloadRequests += 1
            needsSilentReload = true
            Logger.log(
                level: .info,
                "[SilentReload] Coalesced repeat request #\(queuedSilentReloadRequests) (source: \(source))"
            )
            return
        }

        var pass = 1
        repeat {
            isSilentReloadInFlight = true
            needsSilentReload = false

            if pass > 1 {
                Logger.log(
                    level: .info,
                    "[SilentReload] Starting repeated pass #\(pass)"
                )
            }

            async let dishesTask = dishService.getDishes()
            async let chefTask = chefService.current()

            let dishesResult = await dishesTask
            let chefResult = await chefTask

            if case .success(let response) = dishesResult {
                withAnimation(feedAnimation) {
                    dishes = response.data
                }
            }

            if case .success(let chef) = chefResult {
                if currentChef != chef.name {
                    withAnimation(feedAnimation) {
                        currentChef = chef.name
                    }
                    UserDefaults.standard.set(chef.name, forKey: "currentChef")
                }
            }

            isSilentReloadInFlight = false

            if needsSilentReload {
                Logger.log(
                    level: .info,
                    "[SilentReload] Re-running due to \(queuedSilentReloadRequests) repeated request(s)"
                )
                queuedSilentReloadRequests = 0
                pass += 1
            }
        } while needsSilentReload

        queuedSilentReloadRequests = 0
    }
	
	// MARK: - Public Methods
	
	func toggleFavorite(dishId: Int) {
		Task {
			await toggleFavoriteRequest(dishId: dishId)
		}
	}
	
	func deleteDish(dishId: Int) {
		Task {
			await deleteDishRequest(dishId: dishId)
		}
	}
	
	func deleteAllDishes() {
		Task {
			await deleteAllDishesRequest()
		}
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

    private func setupCleanupObserver() {
        NotificationCenter.default.addObserver(
            forName: .dailyCleanupDidFinish,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            Task {
                withAnimation(self.feedAnimation) {
                    self.dishes = []
                    self.currentChef = nil
                }
                await self.silentReloadAll(source: "daily-cleanup-observer")
            }
        }
    }
	
	// MARK: - Private Methods

	private func toggleFavoriteRequest(dishId: Int) async {
		guard role.permissions.canToggleFavorite,
			  let index = dishes.firstIndex(where: { $0.id == dishId }) else { return }

		let newValue = !dishes[index].favourite
		withAnimation(feedAnimation) {
			dishes[index].favourite = newValue
		}

		let result = newValue
			? await dishService.mark(request: MarkDishRequest(ids: [dishId]))
			: await dishService.unmark(request: UnMarkDishRequest(ids: [dishId]))

		if case .networkError = result {
			withAnimation(feedAnimation) {
				dishes[index].favourite.toggle()
			}
		}

		await silentReloadAll(source: "toggle-favorite")
	}

	private func deleteDishRequest(dishId: Int) async {
		guard role.permissions.canDeleteDish else { return }

		let result = await dishService.delete(request: DeleteDishRequest(id: dishId))
		if case .success = result {
			withAnimation(feedAnimation) {
				dishes.removeAll { $0.id == dishId }
			}
		}

		await silentReloadAll(source: "delete-dish")
	}

	private func deleteAllDishesRequest() async {
		guard role.permissions.canDeleteDish else { return }

		let result = await dishService.deleteAll()
		if case .success = result {
			withAnimation(feedAnimation) {
				dishes = []
			}
		}

		await silentReloadAll(source: "delete-all-dishes")
	}

}
