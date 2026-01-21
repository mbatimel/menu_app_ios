import Foundation

class Requester {

    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T> {

        guard let url = URL(string: API.baseURL + endpoint.path) else {
            print("Invalid URL")
            return .networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.parameters {
            configureRequest(&request, with: body, method: endpoint.method)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response from server")
                return .networkError("No response from server")
            }

            let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase

            return handleResponse(httpResponse, data: data, responseModel: responseModel, decoder: decoder)
        } catch {
            print("Network request failed: \(error.localizedDescription)")
            return .networkError("Network request failed: \(error.localizedDescription)")
        }
    }
    
    private func configureRequest(_ request: inout URLRequest, with body: Encodable, method: RequestMethod) {
        switch method {
        case .get:
            var urlComponents = URLComponents(string: request.url?.absoluteString ?? "")
            if let queryItems = body.toQueryItems() {
                urlComponents?.queryItems = queryItems
            }
            request.url = urlComponents?.url
        case .post, .put, .delete, .patch:
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                let jsonData = try encoder.encode(body)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch {
                print("Error encoding JSON:", error)
            }
        }
    }
    
    private func handleResponse<T: Decodable>(_ httpResponse: HTTPURLResponse, data: Data, responseModel: T.Type, decoder: JSONDecoder) -> Result<T> {
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decodedResponse = try decoder.decode(responseModel, from: data)
                return .success(decodedResponse)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                return .networkError("Failed to decode response: \(error.localizedDescription)")
            }
        default:
            return .networkError("Unexpected status code: \(httpResponse.statusCode)")
        }
    }
}
