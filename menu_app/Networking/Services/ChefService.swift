import Foundation

protocol ChefServiceProtocol: AnyObject {
    func current() async -> Result<ChefDTO>
    func create(request: CreateChefRequest) async -> Result<EmptyDTO>
    func delete() async -> Result<EmptyDTO>
}


class ChefService: Requester, ChefServiceProtocol {
	
	func current() async -> Result<ChefDTO> {
		return await sendRequest(endpoint: ChefEndpoint.current, responseModel: ChefDTO.self)
	}
	
	func create(request: CreateChefRequest) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: ChefEndpoint.create(request: request), responseModel: EmptyDTO.self)
	}

	func delete() async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: ChefEndpoint.delete, responseModel: EmptyDTO.self)
	}

}
