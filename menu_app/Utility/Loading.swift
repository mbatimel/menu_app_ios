import Foundation

// MARK: - AppError

enum AppError: Error {
    case network(String)
    case invalidURL
    case decoding(String)
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network(let msg):   return msg
        case .invalidURL:         return "Неверный URL"
        case .decoding(let msg):  return "Ошибка декодирования: \(msg)"
        }
    }
}

// MARK: - Loading

enum Loading<Item> {
    case loading
    case loaded(Item)
    case failed(AppError)

    var value: Item? {
        switch self {
        case .loading, .failed: nil
        case .loaded(let value): value
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading: true
        default: false
        }
    }

    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }

    var isFailed: Bool {
        switch self {
        case .failed: true
        default: false
        }
    }
}

extension Loading where Item == Void {
    static var loaded: Loading<Item> { .loaded(()) }
}
