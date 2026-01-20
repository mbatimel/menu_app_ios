//
//  Chef.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation

struct Chef: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
