import Foundation

@Observable
final class CreateDishViewModel {

	var name: String = ""
	var selectedCategory: DishCategory = .snacks
	var errorMessage: String? = nil

	private let dishService: DishesServiceProtocol

	// MARK: - Init

	init(dishService: DishesServiceProtocol = DishesService()) {
		self.dishService = dishService
	}

	// MARK: - Public Methods

	func createDish() {
		Task {
			await createDishRequest()
		}
	}

	// MARK: - Private Methods

	private func createDishRequest() async {
		let request = CreateDishRequest(dish: name, category: selectedCategory.rawValue)
		let result = await dishService.createDish(request: request)

		switch result {
		case .success:
			Logger.log(level: .info, "Dish successfully created!")
		case .networkError(let error):
			errorMessage = error
		}
	}

}
