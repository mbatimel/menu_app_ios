import Foundation

enum DishesEndpoint: Endpoint {
	case getlist
	case getFavoritesList
	case create(request: CreateDishRequest)
	case update(request: UpdateDishRequest)
    case mark(request:MarkDishRequest)
	case unmark(request: UnMarkDishRequest)
	case deleteDish(id: Int)
	case deleteAll
	
	var path: String {
		switch self {
		case .getlist:
			API.Dishes.list
		case .getFavoritesList:
			API.Dishes.favoriteList
		case .create:
			API.Dishes.create
		case .update:
			API.Dishes.update
		case .mark:
			API.Dishes.mark
		case .unmark:
			API.Dishes.unmark
		case .deleteDish:
			API.Dishes.deleteDish
		case .deleteAll:
			API.Dishes.deleteAll
		}
	}
	
	var method: RequestMethod {
		switch self {
		case .getlist, .getFavoritesList:
			.get
		case .create, .mark, .unmark:
			.post
		case .deleteDish, .deleteAll:
			.delete
		case .update:
			.put
		}
	}
	
	var header: [String : String]? {
		return nil
	}
	
	var parameters: (any Encodable)? {
		switch self {
		case let .create(request):
			request
		case let .update(request):
			request
		case let .mark(request):
            request
		case let .unmark(request):
            request
		case let .deleteDish(id):
			id
		default:
			nil
		}
	}
	
}
