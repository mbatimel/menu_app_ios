import Foundation

class Requester {

    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {

        guard let url = URL(string: API.baseURL + endpoint.path) else {
            throw AppError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header

        if let body = endpoint.parameters {
            configureRequest(&request, with: body, method: endpoint.method)
        }

        Logger.log(level: .info, "→ \(endpoint.method.rawValue) \(request.url?.absoluteString ?? "nil")")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network("No response from server")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(responseModel, from: data)
            } catch {
                throw AppError.decoding(error.localizedDescription)
            }
        default:
            throw AppError.network("Unexpected status code: \(httpResponse.statusCode)")
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
                Logger.log(level: .error(error), "Error encoding request body")
            }
        }
    }
}
