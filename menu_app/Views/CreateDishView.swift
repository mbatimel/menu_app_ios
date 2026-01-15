//
//  CreateDishView.swift
//  menu_app_ios
//
//  Created on 2024
//

import SwiftUI

struct CreateDishView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var dishName = ""
    @State private var selectedCategory: DishCategory = .snacks
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Информация о блюде") {
                    TextField("Название блюда", text: $dishName)
                    
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(DishCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Новое блюдо")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        Task {
                            await viewModel.createDish(
                                name: dishName,
                                category: selectedCategory
                            )
                        }
                    }
                    .disabled(dishName.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

