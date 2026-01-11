//
//  SettingsView.swift
//  menu_app_ios
//
//  Created on 2024
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MenuViewModel
    @State private var secretId: String = UserDefaults.standard.string(forKey: "secretId") ?? "YOUR_SECRET_UUID_HERE"
    @State private var chefName = ""
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Настройки") {
                    TextField("Secret ID", text: $secretId)
                        .textContentType(.none)
                        .autocapitalization(.none)
                    
                    Button("Сохранить Secret ID") {
                        UserDefaults.standard.set(secretId, forKey: "secretId")
                        APIService.shared.setSecretId(secretId)
                    }
                }
                
                Section("Шеф-повар") {
                    TextField("Имя шефа", text: $chefName)
                    
                    Button("Создать шефа") {
                        Task {
                            await createChef()
                        }
                    }
                    .disabled(chefName.isEmpty)
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
    
    private func createChef() async {
        let request = CreateChefRequest(name: chefName)
        do {
            try await APIService.shared.createChef(request)
            UserDefaults.standard.set(chefName, forKey: "currentChef")
            viewModel.currentChef = chefName
            chefName = ""
        } catch {
            print("Ошибка создания шефа: \(error)")
        }
    }
}

