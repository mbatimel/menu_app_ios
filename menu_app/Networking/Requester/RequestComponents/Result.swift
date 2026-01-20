//
//  Result.swift
//  Box
//
//  Created by Шарап Бамматов on 14.06.2024.
//

import Foundation

enum Result<T> {
    case success(_ response: T)
    case networkError(_ err: String)
}
