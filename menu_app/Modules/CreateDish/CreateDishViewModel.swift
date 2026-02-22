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
        do {
            try await dishService.createDish(request: CreateDishRequest(dish: name, category: selectedCategory))
            Logger.log(level: .info, "Dish successfully created!")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
