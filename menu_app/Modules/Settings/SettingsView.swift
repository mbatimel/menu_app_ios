import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @State private var viewModel: SettingsViewModel
    let onChefChanged: () async -> Void
    @FocusState private var isChefFieldFocused: Bool

    init(
        initialChef: String?,
        onChefChanged: @escaping () async -> Void = {}
    ) {
        _viewModel = State(initialValue: SettingsViewModel(currentChef: initialChef))
        self.onChefChanged = onChefChanged
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MenuSpacing.xxxl) {

                // Заголовок секции
                Text("Шеф-повар")
                    .font(Typography.settingsSectionTitle)
                    .foregroundStyle(MenuColors.section)

                // Карточка
                VStack(alignment: .leading, spacing: MenuSpacing.xxl) {

                    // Текущий шеф
                    VStack(alignment: .leading, spacing: MenuSpacing.sm) {
                        Text("Текущий шеф-повар")
                            .font(Typography.caption)
                            .foregroundStyle(MenuColors.secondary)

                        Text(viewModel.currentChef ?? "Не задан")
                            .font(Typography.settingsChefValue)
                            .foregroundStyle(
                                viewModel.hasChef ? MenuColors.text : MenuColors.secondary
                            )
                    }

                    // Поле ввода — только если шефа нет
                    if !viewModel.hasChef {
                        ZStack(alignment: .leading) {
                            if viewModel.chefName.isEmpty {
                                Text("Имя шеф-повара")
                                    .foregroundStyle(.black)
                                    .font(Typography.fieldValueMedium)
                                    .padding(.horizontal, MenuSpacing.lg)
                            }

                            TextField("", text: $viewModel.chefName)
                                .focused($isChefFieldFocused)
                                .foregroundStyle(MenuColors.text)
                                .tint(MenuColors.section)
                                .font(Typography.fieldValueMedium)
                        }
                        .padding(.vertical, MenuSpacing.lg)
                        .padding(.horizontal, MenuSpacing.lg)
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
                    VStack(spacing: MenuSpacing.lg) {

                        // Создать
                        Button {
                            Task {
                                let didCreate = await viewModel.createChef()
                                guard didCreate else { return }

                                await onChefChanged()
                                dismiss()
                            }
                        } label: {
                            Text("Создать шефа")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, MenuSpacing.lg)
                                .font(Typography.actionPrimary)
                                .foregroundStyle(
                                    (!viewModel.hasChef && !viewModel.chefName.isEmpty)
                                    ? MenuColors.background
                                    : MenuColors.secondary
                                )
                                .background(
                                    (!viewModel.hasChef && !viewModel.chefName.isEmpty)
                                    ? MenuColors.section
                                    : MenuColors.paper
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(
                            viewModel.hasChef
                            || viewModel.chefName.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                            || viewModel.isProcessing
                        )

                        // Удалить
                        Button {
                            Task {
                                let didDelete = await viewModel.deleteChef()
                                guard didDelete else { return }
                                await onChefChanged()
                            }
                        } label: {
                            Text("Удалить шефа")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, MenuSpacing.lg)
                                .font(Typography.actionSecondary)
                                .foregroundStyle(
                                    viewModel.hasChef ? MenuColors.destructive : MenuColors.secondary
                                )
                                .background(MenuColors.paper)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!viewModel.hasChef || viewModel.isProcessing)
                    }
                }
                .padding(MenuSpacing.xxl)
                .background(MenuColors.paper)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, MenuSpacing.xl)
            .padding(.top, MenuSpacing.xxxl)
        }
        .background(MenuColors.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Настройки")
                    .font(Typography.settingsNavTitle)
                    .foregroundStyle(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") {
                    dismiss()
                }
                .foregroundStyle(MenuColors.section)
                .font(Typography.toolbarAction)
            }
        }
        .task {
            await viewModel.loadCurrentChef()
        }
        .alert(
            "Ошибка",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            ),
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }
}
