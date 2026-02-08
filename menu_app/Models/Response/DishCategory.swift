import Foundation

enum DishCategory: String, Codable, CaseIterable, Identifiable {

	var id: String { self.rawValue }

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
