//
//  DecorativeDivider.swift
//  menu_app
//
//  Created by M-batimel@ on 28.01.2026.
//
import SwiftUI

struct DecorativeDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(MenuColors.divider)
                .frame(height: 1)

            Image(systemName: "leaf.fill")
                .font(.caption)
                .foregroundColor(MenuColors.section)

            Rectangle()
                .fill(MenuColors.divider)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
        .opacity(0.6)
    }
}

