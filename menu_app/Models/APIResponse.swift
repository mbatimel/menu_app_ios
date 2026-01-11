//
//  APIResponse.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T
    let error: Bool
    let errorText: String
    let additionalErrors: [String]?
}

