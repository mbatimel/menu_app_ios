//
//  MenuListView.swift
//  menu_app_ios
//
//  Created on 2024
//

import SwiftUI

struct MenuListView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var selectedTab = 0
    @State private var selectedDishes: Set<Int> = []
    @State private var editingDish: Dish?
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Все блюда").tag(0)
                    Text("Избранное").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List {
                        ForEach(selectedTab == 0 ? viewModel.dishes : viewModel.favoriteDishes) { dish in
                            DishRowView(
                                dish: dish,
                                isSelected: selectedDishes.contains(dish.id),
                                onToggleSelection: {
                                    if selectedDishes.contains(dish.id) {
                                        selectedDishes.remove(dish.id)
                                    } else {
                                        selectedDishes.insert(dish.id)
                                    }
                                },
                                onEdit: {
                                    editingDish = dish
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteDish(id: dish.id)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Меню")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Настройки") {
                        viewModel.showingSettings = true
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !selectedDishes.isEmpty {
                        Button("Отметить") {
                            Task {
                                await viewModel.markDishes(ids: Array(selectedDishes))
                                selectedDishes.removeAll()
                            }
                        }
                    }
                    
                    Button("Добавить") {
                        viewModel.showingCreateDish = true
                    }
                    
                    Menu {
                        Button("Удалить все", role: .destructive) {
                            Task {
                                await viewModel.deleteAllDishes()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateDish) {
                CreateDishView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
            }
            .sheet(item: $editingDish) { dish in
                EditDishView(viewModel: viewModel, dish: dish)
            }
            .task {
                await viewModel.loadAllDishes()
            }
            .onChange(of: selectedTab) { _ in
                if selectedTab == 1 {
                    Task {
                        await viewModel.loadFavoriteDishes()
                    }
                }
            }
        }
    }
}

struct DishRowView: View {
    let dish: Dish
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                
                HStack {
                    Text(dish.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if dish.favorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            Menu {
                Button("Редактировать", action: onEdit)
                Button("Удалить", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .padding(.vertical, 4)
    }
}

