//
//  LocalModels.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation

// Локальные модели для NavigationStack (отдельные от основных моделей API)

enum LocalDishType: String, CaseIterable {
    case snacks = "Закуски"
    case salads = "Салаты"
    case soups = "Супы"
    case hot_dishes = "Горячие блюда"
    case side_dishes = "Гарниры"
}

struct LocalDish: Identifiable {
    let id = UUID()
    var name: String
    var type: LocalDishType
}

struct LocalMenu: Identifiable {
    let id = UUID()
    var author: String
    var date: Date
    var dishes: [LocalDish]
}

