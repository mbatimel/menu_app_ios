//
//  Dish.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation

enum DishCategory: String, Codable, CaseIterable {
    case snacks = "snacks"
    case salads = "salads"
    case soups = "soups"
    case hotDishes = "hot_dishes"
    case sideDishes = "side_dishes"
    
    var displayName: String {
        switch self {
        case .snacks: return "Закуски"
        case .salads: return "Салаты"
        case .soups: return "Супы"
        case .hotDishes: return "Горячие блюда"
        case .sideDishes: return "Гарниры"
        }
    }
}

struct Dish: Codable, Identifiable {
    let id: Int
    let name: String
    let category: DishCategory
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case favorite = "choice"  // API использует "choice", маппим на "favorite"
    }
}

struct CreateDishRequest: Codable {
    let dish: String
    let categoty: String  // Опечатка в API, оставляем как есть
    
    init(dish: String, category: DishCategory) {
        self.dish = dish
        self.categoty = category.rawValue
    }
}

struct UpdateDishRequest: Codable {
    let id: Int
    let text: String
}

struct MarkDishesRequest: Codable {
    let ids: [Int]
}

struct DeleteDishRequest: Codable {
    let id: Int
}
