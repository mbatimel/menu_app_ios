//
//  UpdateDishRequest.swift
//  menu_app
//
//  Created by Захар Литвинчук on 20.01.2026.
//

import Foundation

struct UpdateDishRequest: Encodable {
    let id: Int
    let text: String
}
