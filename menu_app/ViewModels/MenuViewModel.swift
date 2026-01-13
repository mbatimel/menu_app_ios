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

    @Published var currentChef: String? {
        didSet {
            if let chef = currentChef {
                UserDefaults.standard.set(chef, forKey: "currentChef")
            }
        }
    }

    private let apiService = APIService.shared


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
    init() {
        currentChef = UserDefaults.standard.string(forKey: "currentChef")
    }


    // MARK: - Load

    func loadAllDishes() async {
        isLoading = true
        errorMessage = nil
        do {
            dishes = try await apiService.getAllDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Create

    func createDish(name: String, category: DishCategory) async {
        isLoading = true
        errorMessage = nil

        do {
            try await apiService.createDish(
                CreateDishRequest(dish: name, category: category)
            )
            await loadAllDishes()
            showingCreateDish = false
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Update (МГНОВЕННО)

    func updateDish(id: Int, newName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await apiService.updateDish(
                UpdateDishRequest(id: id, text: newName)
            )

            if let index = dishes.firstIndex(where: { $0.id == id }) {
                dishes[index].name = newName
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Favorite (МГНОВЕННО)

    func toggleFavorite(dishId: Int) async {
        guard let index = dishes.firstIndex(where: { $0.id == dishId }) else { return }

        let newValue = !dishes[index].favorite
        dishes[index].favorite = newValue   // UI обновляется сразу

        do {
            if newValue {
                try await apiService.markDishes(
                    MarkDishesRequest(ids: [dishId])
                )
            } else {
                try await apiService.unmarkDishes(
                    MarkDishesRequest(ids: [dishId])
                )
            }
        } catch {
            dishes[index].favorite.toggle() // rollback
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteDish(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            try await apiService.deleteDish(
                DeleteDishRequest(id: id)
            )
            dishes.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteAllDishes() async {
        isLoading = true
        errorMessage = nil

        do {
            try await apiService.deleteAllDishes()
            dishes = []
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    

}
