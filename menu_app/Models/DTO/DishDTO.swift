import Foundation

struct DishDTO: Codable {
	let data: [Dish]
	let error: Bool
	let errorText: String
}
