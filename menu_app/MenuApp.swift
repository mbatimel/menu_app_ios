import SwiftUI

@main
struct MenuApp: App {
	private let dailyCleanupService = DailyCleanupService()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        dailyCleanupService.scheduleDailyCleanup()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    await dailyCleanupService.checkAndPerformCleanupIfNeeded()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await dailyCleanupService.checkAndPerformCleanupIfNeeded()
                }
            }
        }
    }
}
