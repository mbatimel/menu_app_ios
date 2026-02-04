import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @Bindable var menuViewModel: MenuViewModel
    @State private var viewModel = SettingsViewModel()
    @FocusState private var isChefFieldFocused: Bool

    private var hasChef: Bool {
        if let chef = menuViewModel.currentChef {
            return !chef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Заголовок секции
                Text("Шеф-повар")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(MenuColors.section)

                // Карточка
                VStack(alignment: .leading, spacing: 20) {

                    // Текущий шеф
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Текущий шеф-повар")
                            .font(.caption)
                            .foregroundStyle(MenuColors.secondary)

                        Text(hasChef ? menuViewModel.currentChef! : "Не задан")
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(
                                hasChef ? MenuColors.text : MenuColors.secondary
                            )
                    }

                    // Поле ввода — только если шефа нет
                    if !hasChef {
                        ZStack(alignment: .leading) {
                            if viewModel.chefName.isEmpty {
                                Text("Имя шеф-повара")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .padding(.horizontal, 12)
                            }

                            TextField("", text: $viewModel.chefName)
                                .focused($isChefFieldFocused)
                                .foregroundStyle(MenuColors.text)
                                .tint(MenuColors.section)
                                .font(.system(size: 16, weight: .medium, design: .serif))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(MenuColors.paper)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isChefFieldFocused
                                        ? MenuColors.section
                                        : MenuColors.secondary.opacity(0.4),
                                    lineWidth: isChefFieldFocused ? 2 : 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.15), value: isChefFieldFocused)

                    }

                    // Кнопки
                    VStack(spacing: 12) {

                        // Создать
                        Button {
                            Task {
                                await viewModel.createChef()
                                await menuViewModel.loadCurrentChef()
                                dismiss()
                            }
                        } label: {
                            Text("Создать шефа")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundStyle(
                                    (!hasChef && !viewModel.chefName.isEmpty)
                                    ? MenuColors.background
                                    : MenuColors.secondary
                                )
                                .background(
                                    (!hasChef && !viewModel.chefName.isEmpty)
                                    ? MenuColors.section
                                    : MenuColors.paper
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(hasChef || viewModel.chefName.isEmpty)

                        // Удалить
                        Button {
                            Task {
                                let success = await viewModel.deleteChef()
                                if success {
                                    await MainActor.run {
                                        menuViewModel.currentChef = nil
                                    }
                                }
                            }
                        } label: {
                            Text("Удалить шефа")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundStyle(
                                    hasChef ? MenuColors.destructive : MenuColors.secondary
                                )
                                .background(MenuColors.paper)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!hasChef)
                    }
                }
                .padding(20)
                .background(MenuColors.paper)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(MenuColors.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Настройки")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") {
                    dismiss()
                }
                .foregroundStyle(MenuColors.section)
                .fontWeight(.semibold)
            }
        }
    }
}
