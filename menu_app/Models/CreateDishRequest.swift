//
//  CreateDishRequest.swift
//  menu_app
//
//  Created by Захар Литвинчук on 20.01.2026.
//

import Foundation

struct CreateDishRequest: Encodable {
	let dish: String
	let category: String

	enum CodingKeys: String, CodingKey {
		case dish
		case category = "categoty"
	}

}
