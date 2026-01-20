//
//  DishesService.swift
//  menu_app
//
//  Created by Захар Литвинчук on 20.01.2026.
//

import Foundation

protocol DishesServiceProtocol: AnyObject {

	func getDishes() async -> Result<DishDTO>
	func getfavoriteDishes() async -> Result<[Dish]>
	func createDish(request: CreateDishRequest) async -> Result<EmptyDTO>
	func updateDish(request: UpdateDishRequest) async -> Result<EmptyDTO>
	func mark(ids: [Int]) async -> Result<EmptyDTO>
	func unmark(ids: [Int]) async -> Result<EmptyDTO>
	func delete(id: Int) async -> Result<EmptyDTO>
	func deleteAll() async -> Result<EmptyDTO>

}

class DishesService: Requester, DishesServiceProtocol {

	func getDishes() async -> Result<DishDTO> {
		return await sendRequest(endpoint: DishesEndpoint.getlist, responseModel: DishDTO.self)
	}

	func getfavoriteDishes() async -> Result<[Dish]> {
		return await sendRequest(endpoint: DishesEndpoint.getFavoritesList, responseModel: [Dish].self)
	}

	func createDish(request: CreateDishRequest) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.create(request: request), responseModel: EmptyDTO.self)
	}

	func updateDish(request: UpdateDishRequest) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.update(request: request), responseModel: EmptyDTO.self)
	}

	func mark(ids: [Int]) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.mark(ids: ids), responseModel: EmptyDTO.self)
	}

	func unmark(ids: [Int]) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.unmark(ids: ids), responseModel: EmptyDTO.self)
	}

	func delete(id: Int) async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.deleteDish(id: id), responseModel: EmptyDTO.self)
	}

	func deleteAll() async -> Result<EmptyDTO> {
		return await sendRequest(endpoint: DishesEndpoint.deleteAll, responseModel: EmptyDTO.self)
	}

}
