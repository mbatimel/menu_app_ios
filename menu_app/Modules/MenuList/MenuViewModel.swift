import Foundation
import SwiftUI

@MainActor
@Observable
class MenuViewModel {

    // MARK: - State
	var dishes: [Dish] = []

	var selectedDishes: Set<Int> = []
	var editingDish: Dish?

	var selectedTab = 0
	var showingCreateDish = false
	var showingSettings = false
	var isLoading = false
	var errorMessage: String?
    var currentChef: String?

    
	var role: UserRole = .user {
        didSet {
            UserDefaults.standard.set(role.rawValue, forKey: "userRole")
        }
    }

	private let dishService: DishesServiceProtocol
    private let chefService: ChefServiceProtocol


    // MARK: - Computed

    /// Группировка блюд как в меню
    var groupedDishes: [DishCategory: [Dish]] {
        Dictionary(grouping: dishes, by: { $0.category })
    }

    /// Избранные блюда (НЕ храним отдельно)
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

        if let saved = UserDefaults.standard.string(forKey: "userRole"),
           let role = UserRole(rawValue: saved) {
            self.role = role
        }
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

    // MARK: - Update (МГНОВЕННО)

    func updateDish(id: Int, newName: String, newCategory: DishCategory) async {
        guard role.permissions.canEditDish else { return }
        isLoading = true
        errorMessage = nil

        let request = UpdateDishRequest(id: id, text: newName, category: newCategory)
		let result = await dishService.updateDish(request: request)
		switch result {
		case .success:
			if let index = dishes.firstIndex(where: { $0.id == id }) {
				dishes[index].name = newName
                dishes[index].category=newCategory
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

        let newValue = !dishes[index].favourite
        dishes[index].favourite = newValue   // UI обновляется сразу
        let result = newValue ? await dishService.mark(request:MarkDishRequest(ids:[dishId])) : await dishService.unmark(request:UnMarkDishRequest(ids:[dishId]))
		
		switch result {
		case .success:
			break
		case .networkError(let error):
			dishes[index].favourite.toggle()
			errorMessage = error
		}
    }

    // MARK: - Delete

    func deleteDish(id: Int) async {

        guard role.permissions.canDeleteDish else { return }
        isLoading = true
        errorMessage = nil

        let result = await dishService.delete(request: DeleteDishRequest(id:id))
		switch result {
		case .success:
            dishes.removeAll { $0.id == id }
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

    func loadCurrentChef() async {
        isLoading = true
        errorMessage = nil

        let result = await chefService.current()

        switch result {
        case .success(let chef):
            currentChef = chef.name
            UserDefaults.standard.set(chef.name, forKey: "currentChef")
            isLoading = false

        case .networkError(let error):
            currentChef = nil
            errorMessage = error
            isLoading = false

            Logger.log(level: .warning, "Error while fetch chef: \(error)")
        }
    }



}
