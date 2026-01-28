//
//  PaperBackground.swift
//  menu_app
//
//  Created by M-batimel@ on 28.01.2026.
//

import SwiftUI

struct PaperBackground: View {
    var body: some View {
        MenuColors.background
            .overlay(
                Image(systemName: "circle.grid.cross")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.black.opacity(0.015))
            )
            .ignoresSafeArea()
    }
}
