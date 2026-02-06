//
//  MenuColors.swift
//  menu_app
//
//  Created by M-batimel@ on 28.01.2026.
//

import SwiftUI

enum MenuColors {
    static let uiBackground = UIColor(resource: .menuBackground)
    static let uiPaper = UIColor(resource: .menuPaper)
    static let uiText = UIColor(resource: .menuText)
    static let uiSecondary = UIColor(resource: .menuSecondary)
    static let uiSection = UIColor(resource: .menuSection)
    static let uiDivider = UIColor(resource: .menuDivider)
    static let uiDestructive = UIColor(resource: .menuDestructive)
    static let uiPaperSelected = UIColor(resource: .menuPaperSelected)

    static let background = Color(uiColor: uiBackground)
    static let paper = Color(uiColor: uiPaper)
    static let text = Color(uiColor: uiText)
    static let secondary = Color(uiColor: uiSecondary)
    static let section = Color(uiColor: uiSection)
    static let divider = Color(uiColor: uiDivider)
    static let destructive = Color(uiColor: uiDestructive)
    static let paperSelected = Color(uiColor: uiPaperSelected)
}
