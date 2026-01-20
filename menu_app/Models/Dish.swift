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

struct DishDTO: Codable {
	let data: [Dish]
	let error: Bool
	let errorText: String
}

struct Dish: Codable, Identifiable {
    let id: Int
    var name: String
    let category: DishCategory
    var favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case favorite = "choice"  // API использует "choice", маппим на "favorite"
    }
}
