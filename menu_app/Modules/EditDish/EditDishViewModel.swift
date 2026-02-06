import Foundation

@MainActor
@Observable
final class EditDishViewModel {
    var errorMessage: String?
    var isSaving = false
    var selectedDish: Dish

    private let dishService: DishesServiceProtocol

    init(
        selectedDish: Dish,
        dishService: DishesServiceProtocol = DishesService()
    ) {
        self.selectedDish = selectedDish
        self.dishService = dishService
    }

    @discardableResult
    func updateDish() async -> Bool {
        guard !isSaving else { return false }

        let name = selectedDish.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = "Название блюда не должно быть пустым"
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let request = UpdateDishRequest(
            id: selectedDish.id,
            text: name,
            category: selectedDish.category
        )

        let result = await dishService.updateDish(request: request)
        switch result {
        case .success:
            selectedDish.name = name
            errorMessage = nil
            return true
        case .networkError(let error):
            errorMessage = error
            return false
        }
    }
}
