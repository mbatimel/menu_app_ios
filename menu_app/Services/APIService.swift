//
//  APIService.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:9000/menu/api"
    private var secretId: String {
        didSet {
            UserDefaults.standard.set(secretId, forKey: "secretId")
        }
    }
    
    private init() {
        // В реальном приложении это должно храниться в Keychain
        // Для тестирования можно использовать значение по умолчанию
        self.secretId = UserDefaults.standard.string(forKey: "secretId") ?? "YOUR_SECRET_UUID_HERE"
    }
    
    func setSecretId(_ newSecretId: String) {
        secretId = newSecretId
    }
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "x-secret-id": secretId,
            "Cookie": "secretId=\(secretId)"
        ]
    }
    
    // MARK: - Menu API
    
    func getAllDishes() async throws -> [Dish] {
        let url = URL(string: "\(baseURL)/all")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Dish].self, from: data)
    }
    
    func getFavoriteDishes() async throws -> [Dish] {
        let url = URL(string: "\(baseURL)/favorite")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Dish].self, from: data)
    }
    
    func createDish(_ request: CreateDishRequest) async throws {
        let url = URL(string: "\(baseURL)/create")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: httpRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
    
    func updateDish(_ request: UpdateDishRequest) async throws {
        let url = URL(string: "\(baseURL)/update")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "PUT"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: httpRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
    
    func markDishes(_ request: MarkDishesRequest) async throws {
        let url = URL(string: "\(baseURL)/mark")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: httpRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
    
    func deleteDish(_ request: DeleteDishRequest) async throws {
        let url = URL(string: "\(baseURL)/delete")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "DELETE"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: httpRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
    
    func deleteAllDishes() async throws {
        let url = URL(string: "\(baseURL)/all")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
    
    // MARK: - Chef API
    
    func createChef(_ request: CreateChefRequest) async throws {
        let url = URL(string: "\(baseURL)/create/chef")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: httpRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError
        }
    }
}

enum APIError: Error {
    case invalidURL
    case serverError
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .serverError:
            return "Ошибка сервера"
        case .decodingError:
            return "Ошибка декодирования данных"
        }
    }
}
