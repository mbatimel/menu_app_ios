//
//  MenuViewModel.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation
import SwiftUI
import Combine

class MenuViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var favoriteDishes: [Dish] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateDish = false
    @Published var showingSettings = false
    
    private let apiService = APIService.shared
    
    @MainActor
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
    
    @MainActor
    func loadFavoriteDishes() async {
        isLoading = true
        errorMessage = nil
        do {
            favoriteDishes = try await apiService.getFavoriteDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func createDish(name: String, category: DishCategory) async {
        isLoading = true
        errorMessage = nil
        do {
            let request = CreateDishRequest(dish: name, category: category)
            try await apiService.createDish(request)
            await loadAllDishes()
            showingCreateDish = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func updateDish(id: Int, newName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let request = UpdateDishRequest(id: id, text: newName)
            try await apiService.updateDish(request)
            await loadAllDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func markDishes(ids: [Int]) async {
        isLoading = true
        errorMessage = nil
        do {
            let request = MarkDishesRequest(ids: ids)
            try await apiService.markDishes(request)
            await loadAllDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func deleteDish(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let request = DeleteDishRequest(id: id)
            try await apiService.deleteDish(request)
            await loadAllDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func deleteAllDishes() async {
        isLoading = true
        errorMessage = nil
        do {
            try await apiService.deleteAllDishes()
            await loadAllDishes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

