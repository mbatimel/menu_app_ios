import Foundation

protocol DishesServiceProtocol: AnyObject {

    func getDishes(date: String) async throws -> DishDTO
    func getfavoriteDishes(date: String) async throws -> [Dish]
    func createDish(request: CreateDishRequest) async throws
    func updateDish(request: UpdateDishRequest) async throws
    func mark(request: MarkDishRequest) async throws
    func unmark(request: UnMarkDishRequest) async throws
    func delete(request: DeleteDishRequest) async throws
    func deleteAll() async throws

}

class DishesService: Requester, DishesServiceProtocol {

    func getDishes(date: String) async throws -> DishDTO {
        try await sendRequest(endpoint: DishesEndpoint.getlist(date: date), responseModel: DishDTO.self)
    }

    func getfavoriteDishes(date: String) async throws -> [Dish] {
        try await sendRequest(endpoint: DishesEndpoint.getFavoritesList(date: date), responseModel: [Dish].self)
    }

    func createDish(request: CreateDishRequest) async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.create(request: request), responseModel: EmptyDTO.self)
    }

    func updateDish(request: UpdateDishRequest) async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.update(request: request), responseModel: EmptyDTO.self)
    }

    func mark(request: MarkDishRequest) async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.mark(request: request), responseModel: EmptyDTO.self)
    }

    func unmark(request: UnMarkDishRequest) async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.unmark(request: request), responseModel: EmptyDTO.self)
    }

    func delete(request: DeleteDishRequest) async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.deleteDish(request: request), responseModel: EmptyDTO.self)
    }

    func deleteAll() async throws {
        _ = try await sendRequest(endpoint: DishesEndpoint.deleteAll, responseModel: EmptyDTO.self)
    }

}
