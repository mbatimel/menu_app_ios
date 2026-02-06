import SwiftUI

struct RootView: View {

    @AppStorage(UserDefaultsKeys.hasRoleSelected)
    private var hasRoleSelected = false

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
        .onChange(of: menuViewModel.role) { _, _ in
            hasRoleSelected = true
        }
    }
}
