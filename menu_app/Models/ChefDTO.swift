//
//  ChefDTO.swift
//  menu_app
//
//  Created by M-batimel@ on 24.01.2026.
//
struct ChefDTO: Decodable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "data"
    }
}
