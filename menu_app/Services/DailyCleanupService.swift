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
        Logger.log(level: .info, "Сheck started from: \(source)")

        guard let cleanupTime = cleanupTime(for: now) else {
            Logger.log(level: .warning, "Failed to calculate cleanupTime")
            return
        }

        // 1️⃣ Время ещё не пришло
        guard now >= cleanupTime else {
            Logger.log(level: .info, "Skipped: now < cleanupTime")
            return
        }

        // 2️⃣ Уже чистили сегодня
        if let last = UserDefaults.standard.object(
            forKey: lastCleanupKey
        ) as? Date {

            if calendar.isDate(last, inSameDayAs: now) {
                Logger.log(level: .info, "Skipped: already cleaned today")
                return
            }
        } else {
            Logger.log(level: .info, "No previous cleanup found")
        }

        // 3️⃣ Запускаем очистку
        Logger.log(level: .info, "🧹 [Cleanup] STARTING cleanup")

        let success = await perform()

        if success {
            UserDefaults.standard.set(now, forKey: lastCleanupKey)
            Logger.log(level: .info, "FINISHED successfully")

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .dailyCleanupDidFinish,
                    object: nil
                )
            }
        } else {
            Logger.log(level: .warning, "FAILED")
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
    }}
