import Foundation
import SwiftUI
import Combine

@MainActor
class MenuViewModel: ObservableObject {

    // MARK: - State
    @Published var dishes: [Dish] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateDish = false
    @Published var showingSettings = false
	@Published var selectedTab = 0
	@Published var selectedDishes: Set<Int> = []
	@Published var editingDish: Dish?

    @Published var currentChef: String? {
        didSet {
            if let chef = currentChef {
                UserDefaults.standard.set(chef, forKey: "currentChef")
            }
        }
    }
    
    @Published var role: UserRole = .user {
        didSet {
            UserDefaults.standard.set(role.rawValue, forKey: "userRole")
        }
    }

	private let dishService: DishesServiceProtocol

    // MARK: - Computed

    /// Группировка блюд как в меню
    var groupedDishes: [DishCategory: [Dish]] {
        Dictionary(grouping: dishes, by: { $0.category })
    }

    /// Избранные блюда (НЕ храним отдельно)
    var favoriteDishes: [Dish] {
        dishes.filter { $0.favorite }
    }

    // MARK: - Init
    init(dishService: DishesServiceProtocol = DishesService()) {
        if let saved = UserDefaults.standard.string(forKey: "userRole"),
              let role = UserRole(rawValue: saved) {
               self.role = role
           }
           currentChef = UserDefaults.standard.string(forKey: "currentChef")
		self.dishService = dishService
    }


    // MARK: - Public Methods

	func loadAllDishes() async {
		isLoading = true
		errorMessage = nil
		
		let result = await dishService.getDishes()
		switch result {
		case .success(let response):
			dishes = response.data
			isLoading = false
		case .networkError(let error):
			errorMessage = error
			Logger.log(level: .warning, "Error while fetch all dishes")
			isLoading = false
		}
	}


    func createDish(name: String, category: DishCategory) async {
        guard role.permissions.canCreateDish else { return }

           isLoading = true
           errorMessage = nil

		let request = CreateDishRequest(dish: name, categoty: category.rawValue)
		let result = await dishService.createDish(request: request)
		switch result {
		case .success:
			showingCreateDish = false
		case .networkError(let error):
			errorMessage = error
			Logger.log(level: .warning, "Error while create dish \(error)")
		}

		await loadAllDishes()
        isLoading = false
    }

    // MARK: - Update (МГНОВЕННО)

    func updateDish(id: Int, newName: String) async {
        guard role.permissions.canEditDish else { return }
        isLoading = true
        errorMessage = nil

		let request = UpdateDishRequest(id: id, text: newName)
		let result = await dishService.updateDish(request: request)
		switch result {
		case .success:
			if let index = dishes.firstIndex(where: { $0.id == id }) {
				dishes[index].name = newName
			}
			isLoading = false
		case .networkError(let error):
			errorMessage = error
			isLoading = false
			Logger.log(level: .warning, "Error while update dish \(error)")
		}
    }

    // MARK: - Favorite (МГНОВЕННО)

    func toggleFavorite(dishId: Int) async {
        guard role.permissions.canDeleteDish else { return }
		guard let index = dishes.firstIndex(
			where: { $0.id == dishId
			}) else { return }

        let newValue = !dishes[index].favorite
        dishes[index].favorite = newValue   // UI обновляется сразу

		let result = newValue ? await dishService.mark(ids: [dishId]) : await dishService.unmark(ids: [dishId])
		
		switch result {
		case .success:
			break
		case .networkError(let error):
			dishes[index].favorite.toggle()
			errorMessage = error
		}
    }

    // MARK: - Delete

    func deleteDish(id: Int) async {

        guard role.permissions.canDeleteDish else { return }
        isLoading = true
        errorMessage = nil

		let result = await dishService.delete(id: id)
		switch result {
		case .success:
			withAnimation {
				dishes.removeAll { $0.id == id }
			}
			isLoading = false
		case .networkError(let error):
			errorMessage = error
			isLoading = false
		}

    }

	func deleteAllDishes() async {

		guard role.permissions.canDeleteDish else { return }
		isLoading = true
		errorMessage = nil
		let result = await dishService.deleteAll()
		switch result {
		case .success:
			dishes = []
			isLoading = false
		case .networkError(let error):
			errorMessage = error
			isLoading = false
		}

	}

}
