import SwiftUI

struct RootView: View {

    @State private var hasRoleSelected =
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasRoleSelected)

    @State private var menuViewModel = MenuViewModel()

    var body: some View {
        Group {
            if hasRoleSelected {
                NavigationStack {
                    MenuListView(viewModel: menuViewModel)
                }
            } else {
                RoleKeyView(viewModel: menuViewModel)
            }
        }
        .onChange(of: menuViewModel.role) { _ in
            hasRoleSelected = true
        }
    }
}
