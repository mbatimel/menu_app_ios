//
//  APIService.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation
import OSLog
class APIService {
    static let shared = APIService()
    private static let logger = Logger(subsystem: "menu_app_ios", category: "APIService")
    
    private let baseURL = "http://45.129.128.131:80/menu/api"
    private var secretId: String {
        didSet {
            UserDefaults.standard.set(secretId, forKey: "secretId")
        }
    }
    
    private init() {
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
    
    // MARK: - Helper methods
    
    private func logRequest(method: String, url: URL, body: Data? = nil) {
        Self.logger.info("\(method) \(url.absoluteString)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            Self.logger.debug("Request body: \(bodyString)")
        }
    }
    
    private func logResponse(data: Data, response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            Self.logger.info("Response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                Self.logger.debug("Response body: \(responseString)")
            }
        }
    }
    
    // MARK: - Menu API
    
    func getAllDishes() async throws -> [Dish] {
        let url = URL(string: "\(baseURL)/all")!
        logRequest(method: "GET", url: url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            logResponse(data: data, response: response)
            
            let apiResponse = try JSONDecoder().decode(APIResponse<[Dish]>.self, from: data)
            
            if apiResponse.error {
                Self.logger.error("API returned error: \(apiResponse.errorText)")
                throw APIError.serverError
            }
            
            Self.logger.info("Successfully decoded \(apiResponse.data.count) dishes")
            return apiResponse.data
        } catch let decodingError as DecodingError {
            Self.logger.error("Decoding error: \(String(describing: decodingError))")
            throw APIError.decodingError
        } catch {
            Self.logger.error("Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getFavoriteDishes() async throws -> [Dish] {
        let url = URL(string: "\(baseURL)/favorite")!
        logRequest(method: "GET", url: url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            logResponse(data: data, response: response)
            
            let apiResponse = try JSONDecoder().decode(APIResponse<[Dish]>.self, from: data)
            
            if apiResponse.error {
                Self.logger.error("API returned error: \(apiResponse.errorText)")
                throw APIError.serverError
            }
            
            Self.logger.info("Successfully decoded \(apiResponse.data.count) favorite dishes")
            return apiResponse.data
        } catch let decodingError as DecodingError {
            Self.logger.error("Decoding error: \(String(describing: decodingError))")
            throw APIError.decodingError
        } catch {
            Self.logger.error("Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func createDish(_ request: CreateDishRequest) async throws {
        let url = URL(string: "\(baseURL)/create/dish")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "POST", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Dish created successfully")
        } catch {
            Self.logger.error("Error creating dish: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateDish(_ request: UpdateDishRequest) async throws {
        let url = URL(string: "\(baseURL)/update")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "PUT", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "PUT"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Dish updated successfully")
        } catch {
            Self.logger.error("Error updating dish: \(error.localizedDescription)")
            throw error
        }
    }
    
    func markDishes(_ request: MarkDishesRequest) async throws {
        let url = URL(string: "\(baseURL)/mark")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "POST", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Dishes marked successfully")
        } catch {
            Self.logger.error("Error marking dishes: \(error.localizedDescription)")
            throw error
        }
    }
    
    func unmarkDishes(_ request: MarkDishesRequest) async throws {
        let url = URL(string: "\(baseURL)/unmark")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "POST", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Dishes unmarked successfully")
        } catch {
            Self.logger.error("Error unmarking dishes: \(error.localizedDescription)")
            throw error
        }
    }
    
    func toggleFavorite(dishId: Int, isFavorite: Bool) async throws {
        let request = MarkDishesRequest(ids: [dishId])
        
        if isFavorite {
            // Если уже в избранном, убираем через /unmark
            try await unmarkDishes(request)
            Self.logger.info("Dish removed from favorites")
        } else {
            // Если не в избранном, добавляем через /mark
            try await markDishes(request)
            Self.logger.info("Dish added to favorites")
        }
    }
    
    func deleteDish(_ request: DeleteDishRequest) async throws {
        let url = URL(string: "\(baseURL)/delete")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "DELETE", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "DELETE"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Dish deleted successfully")
        } catch {
            Self.logger.error("Error deleting dish: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAllDishes() async throws {
        let url = URL(string: "\(baseURL)/all")!
        logRequest(method: "DELETE", url: url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("All dishes deleted successfully")
        } catch {
            Self.logger.error("Error deleting all dishes: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Chef API
    
    func getCurrentChef() async throws -> Chef? {
        // Предполагаем, что есть endpoint для получения текущего шеф-повара
        // Если такого нет, можно вернуть nil или использовать другой подход
        // Пока возвращаем nil, так как такого endpoint в примерах нет
        return nil
    }
    
    func createChef(_ request: CreateChefRequest) async throws {
        let url = URL(string: "\(baseURL)/create/chef")!
        let requestBody = try JSONEncoder().encode(request)
        logRequest(method: "POST", url: url, body: requestBody)
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        headers.forEach { httpRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        httpRequest.httpBody = requestBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Chef created successfully")
        } catch {
            Self.logger.error("Error creating chef: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteChef() async throws {
        let url = URL(string: "\(baseURL)/chef")!
        logRequest(method: "DELETE", url: url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            logResponse(data: data, response: response)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.logger.error("Server returned error status: \(httpResponse.statusCode)")
                    throw APIError.serverError
                }
            }
            Self.logger.info("Chef deleted successfully")
        } catch {
            Self.logger.error("Error deleting chef: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteChefAndDishes() async throws {
        // Удаляем шеф-повара и все блюда
        try await deleteChef()
        try await deleteAllDishes()
        Self.logger.info("Chef and dishes deleted successfully")
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
