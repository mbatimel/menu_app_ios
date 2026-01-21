import Foundation

@Observable
final class EditDishViewModel {
	var errorMessage: String? = nil
	var selectedDish: Dish

	private let dishService: DishesServiceProtocol
	
	// MARK: - Init

	init(dishService: DishesServiceProtocol = DishesService(), selectedDish: Dish) {
		self.dishService = dishService
		self.selectedDish = selectedDish
	}

	// MARK: - Public Methods

	func updateDish() {
		Task {
			await updateDishRequest()
		}
	}

	// MARK: - Private Methods
	
	private func updateDishRequest() async {
		let request = UpdateDishRequest(id: selectedDish.id, text: selectedDish.name)
		let result = await dishService.updateDish(request: request)
		
		switch result {
		case .success:
			Logger.log(level: .info, "Dish updated: \(selectedDish.id)")
		case .networkError(let error):
			errorMessage = error
		}
	}

}
