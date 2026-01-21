import Foundation

enum Result<T> {
    case success(_ response: T)
    case networkError(_ err: String)
}
