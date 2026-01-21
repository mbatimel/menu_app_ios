import Foundation

protocol ChefServiceProtocol: AnyObject {

	func current() async -> Result<EmptyDTO>
	func create(name: String) async -> Result<EmptyDTO>
	func delete() async -> Result<EmptyDTO>

}

class ChefService: Requester, ChefServiceProtocol {
	
	func current() async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: ChefEndpoint.current, responseModel: EmptyDTO.self)
	}
	
	func create(name: String) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: ChefEndpoint.create(name: name), responseModel: EmptyDTO.self)
	}

	func delete() async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: ChefEndpoint.delete, responseModel: EmptyDTO.self)
	}

}
