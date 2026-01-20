//
//  ChefEndpoint.swift
//  menu_app
//
//  Created by Захар Литвинчук on 20.01.2026.
//

import Foundation

enum ChefEndpoint: Endpoint {
	case current
	case create(name: String)
	case delete

	var path: String {
		switch self {
		case .current:
			API.Chef.current
		case .create:
			API.Chef.create
		case .delete:
			API.Chef.delete
		}
	}

	var method: RequestMethod {
		switch self {
		case .current:
				.get
		case .create:
				.post
		case .delete:
				.delete
		}
	}

	var header: [String : String]? { nil }

	var parameters: (any Encodable)? {
		switch self {
		case let .create(name):
			name
		default: nil
		}
	}

}
