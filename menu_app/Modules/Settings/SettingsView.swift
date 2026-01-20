//
//  SettingsView.swift
//  menu_app_ios
//
//  Created on 2024
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var menuViewModel: MenuViewModel
	@StateObject var viewModel = SettingsViewModel()
	
	var body: some View {
		Form {
			Section("API Настройки") {
				TextField("Secret ID", text: $viewModel.secretId)
					.textContentType(.none)
					.autocapitalization(.none)
				
				Button("Сохранить Secret ID") {
					UserDefaults.standard.set(viewModel.secretId, forKey: "secretId")
					//						APIService.shared.setSecretId(secretId)
					
					let newRole = roleFromSecret(viewModel.secretId)
					menuViewModel.role = newRole
				}
			}
			
			if menuViewModel.role != .user {
				Section("Шеф-повар") {
					TextField("Имя шефа", text: $viewModel.chefName)
					
					Button("Создать шефа") {
						viewModel.createChef()
					}
					.disabled(viewModel.chefName.isEmpty)
				}
			}
			
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
