import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) var dismiss

	@State private var viewModel = SettingsViewModel()
	
	var body: some View {
		Form {
			Section("API Настройки") {
				TextField("Secret ID", text: $viewModel.secretId)
					.textContentType(.none)
					.autocapitalization(.none)
				
				Button("Сохранить Secret ID") {
					UserDefaults.standard.set(viewModel.secretId, forKey: "secretId")

					let newRole = roleFromSecret(viewModel.secretId)
//					menuViewModel.role = newRole
				}
			}
			
//			if menuViewModel.role != .user {
//				Section("Шеф-повар") {
//					TextField("Имя шефа", text: $viewModel.chefName)
//					
//					Button("Создать шефа") {
//						viewModel.createChef()
//					}
//					.disabled(viewModel.chefName.isEmpty)
//				}
//			}
			
		}
		.navigationTitle("Настройки")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("Готово") {
					dismiss()
				}
			}
		}
	}
}

#Preview {
	SettingsView()
}
