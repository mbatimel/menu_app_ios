import SwiftUI

@main
struct MenuApp: App {
	private let dailyCleanupService = DailyCleanupService()

    init() {
        dailyCleanupService.scheduleDailyCleanup()
        checkAndPerformCleanupIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
    
    private func checkAndPerformCleanupIfNeeded() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        let lastCleanup = UserDefaults.standard.object(forKey: "lastCleanupDate") as? Date

        // Берём сегодняшнюю 3:00 МСК
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 3
        components.minute = 0

        guard let todayCleanupTime = calendar.date(from: components) else { return }

        // Если сейчас после 3:00 и ещё не чистили сегодня
        if now >= todayCleanupTime {
            if let last = lastCleanup, calendar.isDate(last, inSameDayAs: now) {
                return
            }

            Task {
                await dailyCleanupService.performCleanup()
                UserDefaults.standard.set(now, forKey: "lastCleanupDate")
            }
        }
    }
}
