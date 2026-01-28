import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @Bindable var menuViewModel: MenuViewModel
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section {
                if let chef = menuViewModel.currentChef {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Текущий шеф-повар")
                            .font(.caption)
                            .foregroundStyle(MenuColors.secondary)

                        Text(chef)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(MenuColors.text)
                    }
                    .padding(.vertical, 4)

                    Divider()

                    Button {
                        Task {
                            await viewModel.deleteChef()
                            await MainActor.run {
                                menuViewModel.currentChef = nil
                            }
                        }
                    } label: {
                        Text("Удалить шефа")
                            .foregroundStyle(MenuColors.destructive)
                            .font(.system(size: 16, weight: .medium, design: .serif))
                    }

                } else {
                    TextField("Имя шеф-повара", text: $viewModel.chefName)
                        .foregroundStyle(MenuColors.text)
                        .tint(MenuColors.section)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                    Button {
                        Task {
                            await viewModel.createChef()
                            await menuViewModel.loadCurrentChef()
                        }
                        dismiss()
                    } label: {
                        Text("Создать шефа")
                            .foregroundStyle(MenuColors.section)
                            .fontWeight(.semibold)
                        
                    }
                    .disabled(viewModel.chefName.isEmpty)
                }
            } header: {
                Text("Шеф-повар")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(MenuColors.section)
            }
            .listRowBackground(MenuColors.paper)  
        }
        .scrollContentBackground(.hidden)
        .background(MenuColors.background)
        .navigationTitle("Настройки")
        .toolbar {
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
