import Foundation

struct Chef: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
