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
            print("🚀 [Cleanup] perform() called")

            async let dishes = DishesService().deleteAll()
            async let chef = ChefService().delete()

            let dishesResult = await dishes
            let chefResult = await chef

            let dishesSuccess: Bool
            switch dishesResult {
            case .success:
                print("🍽 Dishes deleted")
                dishesSuccess = true
            case .networkError:
                print("❌ Dishes delete failed")
                dishesSuccess = false
            }

            switch chefResult {
            case .success:
                print("👨‍🍳 Chef deleted")
                UserDefaults.standard.removeObject(forKey: "currentChef")
            case .networkError:
                print("❌ Chef delete failed")
            }

            return dishesSuccess
        }
    }
}
