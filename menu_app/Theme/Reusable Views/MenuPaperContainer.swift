//
//  MenuPaperContainer.swift
//  menu_app
//
//  Created by M-batimel@ on 02.02.2026.
//

import SwiftUI

struct MenuPaperContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            MenuColors.paper

            content
                .padding(MenuSpacing.xxl)

            // Цветы по углам
            VStack {
                HStack {
                    FloralCorner(rotation: 0)
                    Spacer()
                    FloralCorner(rotation: 90)
                }
                Spacer()
                HStack {
                    FloralCorner(rotation: -90)
                    Spacer()
                    FloralCorner(rotation: 180)
                }
            }
            .padding(MenuSpacing.lg)
        }
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        .padding(.horizontal, MenuSpacing.xl)
    }
}
