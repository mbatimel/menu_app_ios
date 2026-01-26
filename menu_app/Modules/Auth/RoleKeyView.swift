//
//  RoleKeyView.swift
//  menu_app
//
//  Created by M-batimel@ on 26.01.2026.
//

import SwiftUI

struct RoleKeyView: View {

    @State private var secret: String = ""
    @State private var error: String?
    @State private var isDone = false

    @State var viewModel: MenuViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Введите ключ доступа")
                    .font(.title2)

                SecureField("Ключ", text: $secret)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if let error {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Продолжить") {
                    handleSecret()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle("Авторизация")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isDone) {
                // после успешного ввода сразу в основное меню
                MenuListView(viewModel: viewModel)
            }
        }
    }

    private func handleSecret() {
        guard !secret.isEmpty else {
            error = "Введите ключ"
            return
        }
        let role = roleFromSecret(secret)
        viewModel.applySecret(secret)

        
        isDone = true
    }
}
