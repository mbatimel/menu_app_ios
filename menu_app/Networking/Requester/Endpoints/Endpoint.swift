import Foundation

protocol Endpoint {
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var parameters: Encodable? { get }
}
