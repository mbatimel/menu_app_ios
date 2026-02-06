import SwiftUI

struct RoleKeyView: View {

    @State private var secret: String = ""
    @State private var error: String?

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

                    VStack(spacing: MenuSpacing.xxl) {
                        Image(systemName: "lock.shield")
                            .font(Typography.authIcon)
                            .foregroundStyle(.tint)

                        Text("Доступ к меню")
                            .font(Typography.authTitle)

                        Text("Введите ключ доступа для продолжения")
                            .font(Typography.helperFootnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        SecureField("Ключ доступа", text: $secret)
                            .textContentType(.password)
                            .padding(MenuSpacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )

                        if let error {
                            Text(error)
                                .font(Typography.helperFootnote)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }

                        Button {
                            handleSecret()
                        } label: {
                            Text("Продолжить")
                                .frame(maxWidth: .infinity)
                                .padding(MenuSpacing.xl)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(MenuSpacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 12)
                    )
                    .padding(.horizontal, MenuSpacing.xxxl)

                    Spacer()
                }
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
    }
}
