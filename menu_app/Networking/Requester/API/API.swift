import Foundation

struct API {

	static let baseURL = "http://45.129.128.131:80/menu/api"

	enum Dishes {
		static let list = "/all"
		static let favoriteList = "/favorite"
		static let create = "/create/dish"
		static let update = "/update"
		static let mark = "/mark"
		static let unmark = "/unmark"
		static let deleteDish = "/delete"
		static let deleteAll = "/delete/all"
	}

	enum Chef {
		static let current = "chef"
		static let create = "/create/chef"
		static let delete = "/chef"
	}

}
