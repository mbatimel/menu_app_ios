import SwiftUI

struct MenuListView: View {
	
	@Bindable var viewModel: MenuViewModel
	
	var body: some View {
		contentView
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(MenuColors.background)
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(MenuColors.background, for: .navigationBar)
			.toolbarColorScheme(.light, for: .navigationBar)
			.toolbar {
				
				ToolbarItem(placement: .navigationBarLeading) {
					if viewModel.role.permissions.canChangeChef {
						Button {
							viewModel.openSettings()
						} label: {
							Image(systemName: "gear")
								.foregroundColor(MenuColors.section)
						}
					}
				}
				
				ToolbarItemGroup(placement: .navigationBarTrailing) {
					
					if viewModel.role.permissions.canCreateDish {
						Button("Добавить") {
							viewModel.openCreateDish()
						}
						.foregroundColor(MenuColors.section)
					}
					
					if viewModel.role.permissions.canDeleteDish {
						Menu {
							Button("Удалить все", role: .destructive) {
								viewModel.deleteAllDishes()
							}
						} label: {
							Image(systemName: "ellipsis.circle")
								.foregroundColor(MenuColors.section)
						}
					}
				}
			}
			.sheet(item: $viewModel.activeRoute) { route in
				NavigationStack {
					switch route {
					case .createDish:
						CreateDishView(onSaved: {
							await viewModel.silentReloadAll()
						})
					case .settings:
						SettingsView(
							initialChef: viewModel.currentChef,
							onChefChanged: {
								await viewModel.loadCurrentChef()
							}
						)
					case .editDish(let selectedDish):
						EditDishView(
							viewModel: EditDishViewModel(
								selectedDish: selectedDish
							),
							onSaved: {
								await viewModel.silentReloadAll()
							}
						)
					}
				}
			}
			.task {
				await viewModel.loadCurrentChef()
				await viewModel.loadAllDishes()
			}
			.onChange(of: viewModel.selectedDate) {
				Task { await viewModel.loadAllDishes() }
			}
			.onAppear { viewModel.startAutoRefresh() }
			.onDisappear { viewModel.stopAutoRefresh() }
	}
	
	// MARK: - Content View
	
	private var contentView: some View {
		VStack(spacing: .zero) {
			headerView

			switch viewModel.dishesState {
			case .loading:
				loadingView
			case .loaded:
				loadedView()
			case .failed:
				errorView
			}
		}
	}
	
	// MARK: - Header View
	
	private var headerView: some View {
		VStack(spacing: .zero) {
			Text("Меню")
				.font(Typography.screenTitle)
				.foregroundColor(MenuColors.text)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.horizontal, MenuSpacing.xl)
				.padding(.top, MenuSpacing.md)
			
			chefView
				.padding(.top, MenuSpacing.xxs)
			
			MenuToggle(selection: $viewModel.selectedTab)
				.padding(.top, MenuSpacing.md)
				.padding(.bottom, MenuSpacing.sm)
		}
	}
	
	// MARK: - Chef header
	
	private var chefView: some View {
		HStack {
			Text("Шеф-повар: \(viewModel.chefDisplayName)")
				.font(Typography.menuChefName)
				.foregroundColor(MenuColors.text)
				.shimmer(isActive: viewModel.currentChef == nil && viewModel.dishesState.isLoading)
			
			Spacer()
			
			DatePicker("", selection: $viewModel.selectedDate, in: ...Date(), displayedComponents: .date)
				.datePickerStyle(.compact)
				.labelsHidden()
				.tint(MenuColors.section)
				.environment(\.locale, Locale(identifier: "ru_RU"))
		}
		.padding(.horizontal, MenuSpacing.xl)
		.padding(.top, MenuSpacing.xs)
	}
	
	// MARK: - Empty State
	
	private func emptyState(_ text: String) -> some View {
		VStack {
			Spacer()
			Text(text)
				.font(Typography.menuChefDate)
				.foregroundColor(MenuColors.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, MenuSpacing.xl)
			Spacer()
		}
	}
	
	// MARK: - Menu List Wrapper
	
	private func menuList(_ groups: [DishCategory: [Dish]]) -> some View {
		MenuPaperContainer {
			List {
				groupedList(groups)
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.refreshable {
				guard viewModel.isToday else { return }
				await viewModel.silentReloadAll()
			}
		}
	}
	
	// MARK: - Grouped List
	
	@ViewBuilder
	private func groupedList(_ groups: [DishCategory: [Dish]]) -> some View {
		ForEach(DishCategory.allCases, id: \.self) { category in
			if let dishes = groups[category], !dishes.isEmpty {
				Section {
					dishList(dishes)
				} header: {
					VStack(spacing: MenuSpacing.sm) {
						Text(category.displayName.uppercased())
							.font(Typography.sectionHeader)
							.foregroundColor(MenuColors.section)
							.tracking(1)
						
						DecorativeDivider()
					}
					.padding(.top, MenuSpacing.lg)
				}
			}
		}
	}
	
	private func dishList(_ dishes: [Dish]) -> some View {
		ForEach(dishes) { dish in
			DishRowView(
				dish: dish,
				canEdit: viewModel.role.permissions.canEditDish,
				canDelete: viewModel.role.permissions.canDeleteDish,
				onToggleFavorite: {
					viewModel.toggleFavorite(dishId: dish.id)
				},
				onEdit: {
					viewModel.openEditDish(dish)
				},
				onDelete: {
					viewModel.deleteDish(dishId: dish.id)
				}
			)
		}
	}
	
	// MARK: - Loading View
	
	private var loadingView: some View {
		VStack(spacing: .zero) {
			Spacer()
			ProgressView()
			Spacer()
		}
	}
	
	// MARK: - Loaded View
	@ViewBuilder
	private func loadedView() -> some View {
		if viewModel.selectedTab == 0 {
			if viewModel.groupedDishes.isEmpty {
				emptyState("Шеф-повар ещё не добавил блюда, попробуйте позднее...")
			} else {
				menuList(viewModel.groupedDishes)
			}
		} else {
			if viewModel.favoriteDishes.isEmpty {
				emptyState("Нет избранных блюд...")
			} else {
				menuList(
					Dictionary(
						grouping: viewModel.favoriteDishes,
						by: { $0.category }
					)
				)
			}
		}
	}
	
	// MARK: - Error View
	
	private var errorView: some View {
		VStack {
			Spacer()
			Image(systemName: "wifi.exclamationmark")
			Text("Ошибка загрузки данных, повторите попытку позднее...")
				.foregroundColor(.secondary)
			Spacer()
		}
	}

}
