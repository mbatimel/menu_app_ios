import SwiftUI

@main
struct MenuApp: App {

    @Environment(\.scenePhase) private var scenePhase
    private let cleanupService = DailyCleanupService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    await runCleanup(source: "App launch (.task)")
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await runCleanup(source: "scenePhase == .active")
                }
            }
        }
    }

    private func runCleanup(source: String) async {
        await cleanupService.checkAndPerformCleanupIfNeeded(
            source: source
        ) {
            Logger.log(level: .info, "Сalled")

            async let dishesTask: Void = DishesService().deleteAll()
            async let chefTask: Void = ChefService().delete()

            var dishesSuccess = false

            do {
                try await dishesTask
                Logger.log(level: .info, "🍽 Dishes deleted")
                dishesSuccess = true
            } catch {
                Logger.log(level: .error(error), "Dishes delete failed")
            }

            do {
                try await chefTask
                Logger.log(level: .info, "Chef deleted")
                UserDefaults.standard.removeObject(forKey: "currentChef")
            } catch {
                Logger.log(level: .error(error), "Chef delete failed")
            }

            return dishesSuccess
        }
    }
}
