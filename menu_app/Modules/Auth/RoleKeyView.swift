import SwiftUI

struct RoleKeyView: View {

    @State private var secret: String = ""
    @State private var error: String?
    @State private var isDone = false

    @State var viewModel: MenuViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Фон
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    VStack(spacing: 20) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 44))
                            .foregroundStyle(.tint)

                        Text("Доступ к меню")
                            .font(.title2.bold())

                        Text("Введите ключ доступа для продолжения")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        SecureField("Ключ доступа", text: $secret)
                            .textContentType(.password)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )

                        if let error {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }

                        Button {
                            handleSecret()
                        } label: {
                            Text("Продолжить")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 12)
                    )
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $isDone) {
                MenuListView(viewModel: viewModel)
            }
        }
    }

    private func handleSecret() {
        withAnimation {
            error = nil
        }

        guard !secret.isEmpty else {
            withAnimation {
                error = "Введите ключ доступа"
            }
            return
        }

        viewModel.applySecret(secret)
        isDone = true
    }
}
