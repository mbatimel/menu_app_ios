import Foundation

final actor TaskDebouncer {
    private var task: Task<Void, Never>?

    init() {}

    func debounce(
        for interval: Duration = .seconds(0.5),
        action: @Sendable @escaping () async -> Void
    ) {
        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(for: interval)
                try Task.checkCancellation()
                await action()
            } catch is CancellationError {
                Logger.log(level: .info, "Task was cancelled before been executed")
            } catch {
                Logger.log(level: .error(error), "Unexpected error while debouncing task: \(error)")
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
