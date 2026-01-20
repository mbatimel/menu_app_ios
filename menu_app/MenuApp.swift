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
            ContentView()
        }
    }
    
    private func checkAndPerformCleanupIfNeeded() {
        // Проверяем, нужно ли выполнить очистку
        let lastCleanupDate = UserDefaults.standard.object(forKey: "lastCleanupDate") as? Date
        let now = Date()
        
        // Если последняя очистка была более 24 часов назад и сейчас после 3:00 МСК
        if let lastDate = lastCleanupDate {
            let timeSinceLastCleanup = now.timeIntervalSince(lastDate)
            if timeSinceLastCleanup >= 24 * 60 * 60 { // 24 часа
                // Проверяем время (3:00 МСК = 00:00 UTC зимой)
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: now)
                if hour >= 0 && hour < 1 { // Между 00:00 и 01:00 UTC
                    Task {
                        await dailyCleanupService.performCleanup()
                        UserDefaults.standard.set(now, forKey: "lastCleanupDate")
                    }
                }
            }
        } else {
            // Первый запуск - сохраняем текущую дату
            UserDefaults.standard.set(now, forKey: "lastCleanupDate")
        }
    }
}
