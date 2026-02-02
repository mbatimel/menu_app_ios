//
//  MenuToggle.swift
//  menu_app
//
//  Created by M-batimel@ on 02.02.2026.
//

import SwiftUI

struct MenuToggle: View {
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            toggleButton(title: "Все блюда", tag: 0)
            toggleButton(title: "Избранное", tag: 1)
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(MenuColors.paper)
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
        .padding(.horizontal)
    }

    private func toggleButton(title: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                selection = tag
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(selection == tag ? MenuColors.section : MenuColors.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selection == tag ? MenuColors.paperSelected : .clear)
                )
        }
    }
}
