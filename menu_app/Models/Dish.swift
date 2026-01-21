import Foundation

struct Dish: Codable, Identifiable {
    let id: Int
    var name: String
    var category: DishCategory
    var favourite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case favourite = "choice"  // API использует "choice", маппим на "favorite"
    }
}
