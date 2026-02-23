import Foundation

protocol ChefServiceProtocol: AnyObject {
    func current() async throws -> ChefDTO
    func create(request: CreateChefRequest) async throws
    func delete() async throws
}

class ChefService: Requester, ChefServiceProtocol {

    func current() async throws -> ChefDTO {
        try await sendRequest(endpoint: ChefEndpoint.current, responseModel: ChefDTO.self)
    }

    func create(request: CreateChefRequest) async throws {
        _ = try await sendRequest(endpoint: ChefEndpoint.create(request: request), responseModel: EmptyDTO.self)
    }

    func delete() async throws {
        _ = try await sendRequest(endpoint: ChefEndpoint.delete, responseModel: EmptyDTO.self)
    }

}
