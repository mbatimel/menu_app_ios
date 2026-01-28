//
//  MenuTextStyle.swift
//  menu_app
//
//  Created by M-batimel@ on 28.01.2026.
//

import SwiftUI

enum MenuTextStyle {

    // Основной текст блюд
    static let dishTitle = Font.system(
        size: 16,
        weight: .medium,
        design: .serif
    )

    // Категория / вторичный текст
    static let dishSubtitle = Font.system(
        size: 13,
        weight: .regular,
        design: .serif
    )

    // Заголовки секций (Закуски, Супы)
    static let sectionHeader = Font.system(
        size: 15,
        weight: .semibold,
        design: .serif
    )

    // Заголовок экрана "Меню"
    static let screenTitle = Font.system(
        size: 32,
        weight: .bold,
        design: .serif
    )
}
