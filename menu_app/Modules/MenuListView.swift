import SwiftUI

struct MenuListView: View {
	
	@StateObject private var viewModel = MenuViewModel()
	
	var body: some View {
		VStack {
			
			// Шеф-повар
			if let chef = viewModel.currentChef {
				HStack {
					Image(systemName: "person.crop.circle.fill")
						.foregroundColor(.blue)
					Text("Шеф-повар: \(chef)")
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
				.padding(.vertical, 6)
			}
			
			Picker("", selection: $viewModel.selectedTab) {
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
					groupedList(
						viewModel.selectedTab == 0
						? viewModel.groupedDishes
						: Dictionary(
							grouping: viewModel.favoriteDishes,
							by: { $0.category }
						)
					)
				}
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
				
				if viewModel.role.permissions.canCreateDish {
					Button("Добавить") {
						viewModel.showingCreateDish = true
					}
				}
				
				if viewModel.role.permissions.canDeleteDish {
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
		}
		.sheet(isPresented: $viewModel.showingCreateDish) {
			NavigationStack {
				CreateDishView(viewModel: viewModel)
			}
		}
		.sheet(isPresented: $viewModel.showingSettings) {
			NavigationStack {
				SettingsView(menuViewModel: viewModel)
			}
		}
		.sheet(item: $viewModel.editingDish) { dish in
			NavigationStack {
				EditDishView(viewModel: viewModel, dishId: dish.id)
			}
		}
		.task {
			await viewModel.loadAllDishes()
		}
	}
	
	// MARK: - Dish list builder
	
	@ViewBuilder
	private func dishList(_ dishes: [Dish]) -> some View {
		ForEach(Array(dishes.enumerated()), id: \.element.id) { index, dish in
			DishRowView(
				dish: dish,
				isSelected: viewModel.selectedDishes.contains(dish.id),
				canToggleFavorite: viewModel.role.permissions.canToggleFavorite,
				canEdit: viewModel.role.permissions.canEditDish,
				canDelete: viewModel.role.permissions.canDeleteDish,
				onToggleSelection: {
					toggleSelection(dish.id)
				},
				onToggleFavorite: {
					Task {
						await viewModel.toggleFavorite(dishId: dish.id)
					}
				},
				onEdit: {
					viewModel.editingDish = dish
				},
				onDelete: {
					Task {
						await viewModel.deleteDish(id: dish.id)
					}
				},
				index: index + 1
			)
		}
	}
	
	private func toggleSelection(_ id: Int) {
		if viewModel.selectedDishes.contains(id) {
			viewModel.selectedDishes.remove(id)
		} else {
			viewModel.selectedDishes.insert(id)
		}
	}
	
	@ViewBuilder
	private func groupedList(_ groups: [DishCategory: [Dish]]) -> some View {
		ForEach(DishCategory.allCases, id: \.self) { category in
			if let dishes = groups[category], !dishes.isEmpty {
				Section(header: Text(category.displayName)) {
					dishList(dishes)
				}
			}
		}
	}
}
