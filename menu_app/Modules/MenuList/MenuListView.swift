import SwiftUI

struct MenuListView: View {

    @State var viewModel: MenuViewModel

    var body: some View {
        ZStack {
            PaperBackground()

            VStack(spacing: 0) {
                chefView

                Picker("", selection: $viewModel.selectedTab) {
                    Text("Все блюда").tag(0)
                    Text("Избранное").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(MenuColors.paper)
                        .shadow(color: .black.opacity(0.05), radius: 3)
                )
                .padding(.horizontal)
                .tint(MenuColors.section)


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
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden) // 🔥 УБИРАЕМ ЧЁРНЫЙ ФОН
                }
            }
        }
        .navigationTitle("Меню")
        .toolbarTitleDisplayMode(.large)
        .toolbarBackground(MenuColors.background, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.role.permissions.canDeleteDish {
                    Button {
                        viewModel.showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(MenuColors.section)
                    }
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {

                if viewModel.role.permissions.canCreateDish {
                    Button("Добавить") {
                        viewModel.showingCreateDish = true
                    }
                    .foregroundColor(MenuColors.section)
                }
            }
        }
        .task {
            await viewModel.loadCurrentChef()
            await viewModel.loadAllDishes()
        }
    }

 

    // MARK: - Chef & Date Header

    @ViewBuilder
    private var chefView: some View {
        if let chef = viewModel.currentChef {
            HStack {
                
                Text("Шеф-повар: \(chef)")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(MenuColors.text)

                Spacer()

                
                Text(formattedDate())
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(MenuColors.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 6)
        }
    }


    // MARK: - List

    @ViewBuilder
    private func groupedList(_ groups: [DishCategory: [Dish]]) -> some View {
        ForEach(DishCategory.allCases, id: \.self) { category in
            if let dishes = groups[category], !dishes.isEmpty {

                Section {
                    dishList(dishes)
                } header: {
                    VStack(spacing: 6) {
                        Text(category.displayName)
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(MenuColors.section)

                        DecorativeDivider()
                    }
                    .padding(.top, 12)
                }
            }
        }
    }

    private func dishList(_ dishes: [Dish]) -> some View {
        ForEach(dishes) { dish in
            DishRowView(
                dish: dish,
                isSelected: false,
                canToggleFavorite: viewModel.role.permissions.canToggleFavorite,
                canEdit: viewModel.role.permissions.canEditDish,
                canDelete: viewModel.role.permissions.canDeleteDish,
                onToggleSelection: {},
                onToggleFavorite: {
                    Task { await viewModel.toggleFavorite(dishId: dish.id) }
                },
                onEdit: {
                    viewModel.editingDish = dish
                },
                onDelete: {
                    Task { await viewModel.deleteDish(id: dish.id) }
                },
                index: 0
            )
        }
    }
    // MARK: - Date formatter (RU)

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }

}
