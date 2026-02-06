//
//  FloralCorner.swift
//  menu_app
//
//  Created by M-batimel@ on 02.02.2026.
//
import SwiftUI

struct FloralCorner: View {
    let rotation: Double

    var body: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .frame(width: 26, height: 26)
            .foregroundColor(MenuColors.section.opacity(0.35))
            .rotationEffect(.degrees(rotation))
    }
}

