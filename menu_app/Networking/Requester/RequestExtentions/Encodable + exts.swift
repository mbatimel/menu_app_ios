//
//  Encodable + exts.swift
//  Box
//
//  Created by Шарап Бамматов on 02.07.2024.
//

import Foundation

extension Encodable {
    func toQueryItems() -> [URLQueryItem]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: Any] else {
            return nil
        }
        
        return dictionary.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }

    func toPercentEncodedData() -> Data? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: Any] else {
            return nil
        }
        
        let queryItems = dictionary.map { "\($0.key)=\($0.value)" }
        return queryItems.joined(separator: "&").data(using: .utf8)
    }
}
