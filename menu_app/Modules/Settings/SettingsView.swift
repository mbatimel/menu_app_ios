import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @Bindable var menuViewModel: MenuViewModel
    @State private var viewModel = SettingsViewModel()
    var currentChef: String?

    var body: some View {
        Form {

            if menuViewModel.role.permissions.canDeleteDish {

                Section("Шеф-повар") {

                    if let chef = menuViewModel.currentChef {
                        Text("Текущий: \(chef)")

                        Button("Удалить шефа", role: .destructive) {
                            Task {
                                await viewModel.deleteChef()
                                await MainActor.run {
                                    menuViewModel.currentChef = nil
                                }

                            }
                        }


                    } else {
                        TextField("Имя шефа", text: $viewModel.chefName)

                        Button("Создать шефа") {
                            Task {
                                await viewModel.createChef()
                                await menuViewModel.loadCurrentChef()
                            }
                            dismiss()
                        }
                        .disabled(viewModel.chefName.isEmpty)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(MenuColors.background)
        .navigationTitle("Настройки")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") {
                    dismiss()
                }.foregroundStyle(MenuColors.section)
            }
        }
    }
}


#Preview {
    SettingsView(menuViewModel: MenuViewModel())
}
