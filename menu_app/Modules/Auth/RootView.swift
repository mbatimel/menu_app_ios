//
//  RootView.swift
//  menu_app
//
//  Created by M-batimel@ on 26.01.2026.
//
import Foundation
import SwiftUI

struct RootView: View {

    @State private var hasRoleSelected: Bool =
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasRoleSelected)

    @State private var menuViewModel = MenuViewModel()

    var body: some View {
        if hasRoleSelected {
            NavigationStack {
                MenuListView(viewModel: menuViewModel)
            }
        } else {
            RoleKeyView(viewModel: menuViewModel)
                .onChange(of: menuViewModel.role) { _ in
                    hasRoleSelected = true
                }
        }
    }
}
