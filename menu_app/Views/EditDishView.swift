//
//  EditDishView.swift
//  menu_app_ios
//
//  Created on 2024
//

import SwiftUI

struct EditDishView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Environment(\.dismiss) var dismiss
    
    let dish: Dish
    @State private var dishName: String
    
    init(viewModel: MenuViewModel, dish: Dish) {
        self.viewModel = viewModel
        self.dish = dish
        _dishName = State(initialValue: dish.name)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Редактировать блюдо") {
                    TextField("Название блюда", text: $dishName)
                    
                    Text("Категория: \(dish.category.displayName)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.updateDish(id: dish.id, newName: dishName)
                            dismiss()
                        }
                    }
                    .disabled(dishName.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

