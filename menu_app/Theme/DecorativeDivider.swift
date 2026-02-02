//
//  DecorativeDivider.swift
//  menu_app
//
//  Created by M-batimel@ on 28.01.2026.
//
import SwiftUI

struct DecorativeDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(MenuColors.divider)
                .frame(height: 1)

            Image(systemName: "leaf")
                .foregroundColor(MenuColors.section)
                .font(.footnote)

            Rectangle()
                .fill(MenuColors.divider)
                .frame(height: 1)
        }
        .opacity(0.6)
        .padding(.vertical, 6)
    }
}

