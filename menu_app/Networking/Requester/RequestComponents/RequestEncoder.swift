//
//  RequestEncoder.swift
//  Box
//
//  Created by Шарап Бамматов on 15.06.2024.
//

import Foundation

struct RequestEncoder {
    static func json(parameters: [String: Any]) -> Data? {
        guard JSONSerialization.isValidJSONObject(parameters) else {
            print("Invalid JSON object:", parameters)
            return nil
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error serializing JSON:", error)
            return nil
        }
    }
}
