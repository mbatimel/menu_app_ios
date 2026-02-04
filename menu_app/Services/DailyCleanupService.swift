import Foundation

final class DailyCleanupService {

    static let shared = DailyCleanupService()
    private init() {}

    private let cleanupHour = 0
    private let cleanupMinute = 30
    private let lastCleanupKey = "lastCleanupDate"

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal
    }

    // MARK: - Public

    func checkAndPerformCleanupIfNeeded(
        source: String,
        perform: @escaping () async -> Bool
    ) async {
        let now = Date()
        print("🟡 [Cleanup] check started from: \(source)")
        logDate("Now", now)

        guard let cleanupTime = cleanupTime(for: now) else {
            print("🔴 [Cleanup] failed to calculate cleanupTime")
            return
        }

        logDate("Cleanup time today", cleanupTime)

        // 1️⃣ Время ещё не пришло
        guard now >= cleanupTime else {
            print("⏳ [Cleanup] skipped: now < cleanupTime")
            return
        }

        // 2️⃣ Уже чистили сегодня
        if let last = UserDefaults.standard.object(
            forKey: lastCleanupKey
        ) as? Date {
            logDate("Last cleanup", last)

            if calendar.isDate(last, inSameDayAs: now) {
                print("⛔️ [Cleanup] skipped: already cleaned today")
                return
            }
        } else {
            print("ℹ️ [Cleanup] no previous cleanup found")
        }

        // 3️⃣ Запускаем очистку
        print("🧹 [Cleanup] STARTING cleanup")

        let success = await perform()

        if success {
            UserDefaults.standard.set(now, forKey: lastCleanupKey)
            print("✅ [Cleanup] FINISHED successfully")

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .dailyCleanupDidFinish,
                    object: nil
                )
            }
        } else {
            print("❌ [Cleanup] FAILED")
        }
    }

    // MARK: - Helpers

    private func cleanupTime(for date: Date) -> Date? {
        calendar.date(
            bySettingHour: cleanupHour,
            minute: cleanupMinute,
            second: 0,
            of: date
        )
    }

    private func logDate(_ title: String, _ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        formatter.timeZone = .current
        print("   ⏱ \(title): \(formatter.string(from: date))")
    }
}
