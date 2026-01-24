import Foundation

@Observable
final class EditDishViewModel {
    var errorMessage: String? = nil
    var selectedDish: Dish

    private unowned let menuViewModel: MenuViewModel

    init(menuViewModel: MenuViewModel, selectedDish: Dish) {
        self.menuViewModel = menuViewModel
        self.selectedDish = selectedDish
    }

    func updateDish() {
        Task {
            await menuViewModel.updateDish(id: selectedDish.id, newName: selectedDish.name, newCategory: selectedDish.category)
        }
    }
}
