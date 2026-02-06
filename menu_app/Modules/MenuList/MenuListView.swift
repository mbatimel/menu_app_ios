import SwiftUI

struct MenuListView: View {

    @Bindable var viewModel: MenuViewModel

    var body: some View {
        ZStack {
            MenuColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

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

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ZStack {
                        if viewModel.selectedTab == 0 {
                            menuList(viewModel.groupedDishes)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        } else {
                            menuList(
                                Dictionary(
                                    grouping: viewModel.favoriteDishes,
                                    by: { $0.category }
                                )
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedTab)
                }
            }
        }
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
                            Task {
                                await viewModel.deleteAllDishes()
                            }
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
                    CreateDishView()
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
                            await viewModel.silentReloadAll(source: "edit-dish-saved")
                        }
                    )
                }
            }
        }
        .task {
            await viewModel.loadCurrentChef()
            await viewModel.loadAllDishes()
        }
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    // MARK: - Chef header

    @ViewBuilder
    private var chefView: some View {
        if let chef = viewModel.currentChef {
            HStack {
                Text("Шеф-повар: \(chef)")
                    .font(Typography.menuChefName)
                    .foregroundColor(MenuColors.text)

                Spacer()

                Text(formattedDate())
                    .font(Typography.menuChefDate)
                    .foregroundColor(MenuColors.secondary)
            }
            .padding(.horizontal, MenuSpacing.xl)
            .padding(.top, MenuSpacing.xs)
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
                await viewModel.silentReloadAll(source: "pull-to-refresh")
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
                    Task {
                        await viewModel.toggleFavorite(dishId: dish.id)
                    }
                },
                onEdit: {
                    viewModel.openEditDish(dish)
                },
                onDelete: {
                    Task {
                        await viewModel.deleteDish(id: dish.id)
                    }
                }
            )
        }
    }

    // MARK: - Date formatter

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
}
