import Foundation
import UserNotifications

class DailyCleanupService {
	let chefService: ChefServiceProtocol
	let dishService: DishesServiceProtocol

    static let notificationId = "dailyCleanup"
    private static let lastCleanupKey = "lastCleanupDate"

    private let cleanupHour = 0
    private let cleanupMinute = 5

    private var cleanupTimeZone: TimeZone {
        .current
    }

    private var cleanupCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = cleanupTimeZone
        return calendar
    }
	
	init(
		chefService: ChefServiceProtocol = ChefService(),
		dishService: DishesServiceProtocol = DishesService()
	) {
		self.chefService = chefService
		self.dishService = dishService
	}

    func scheduleDailyCleanup() {
        let center = UNUserNotificationCenter.current()
        
        // Запрашиваем разрешение на уведомления
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
                return
            }
            
            if granted {
                self.setupDailyNotification()
            } else {
            }
        }
    }
    
    private func setupDailyNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Удаляем предыдущие уведомления
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationId])

        var dateComponents = DateComponents()
        dateComponents.hour = cleanupHour
        dateComponents.minute = cleanupMinute
        dateComponents.timeZone = cleanupTimeZone
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Очистка меню"
        content.body = "Выполняется ежедневная очистка меню"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: Self.notificationId,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
        }
        
        // Регистрируем обработчик уведомлений
        center.delegate = NotificationDelegate.shared
    }
    
    func checkAndPerformCleanupIfNeeded(now: Date = Date()) async {
        guard shouldPerformCleanup(now: now) else { return }
        let cleaned = await performCleanup()
        if cleaned {
            UserDefaults.standard.set(now, forKey: Self.lastCleanupKey)
        }
    }

    @discardableResult
    func performCleanup() async -> Bool {
		async let chefResult = chefService.delete()
		async let dishesResult = dishService.deleteAll()

        let dishes = await dishesResult
        let chef = await chefResult

        let dishesSuccess: Bool
        switch dishes {
        case .success:
            dishesSuccess = true
        case .networkError:
            dishesSuccess = false
        }

        let chefSuccess: Bool
        switch chef {
        case .success:
            chefSuccess = true
        case .networkError:
            chefSuccess = false
        }

        if chefSuccess {
            UserDefaults.standard.removeObject(forKey: "currentChef")
        }

        return dishesSuccess
    }

    private func shouldPerformCleanup(now: Date) -> Bool {
        let calendar = cleanupCalendar
        guard let cleanupTime = calendar.date(
            bySettingHour: cleanupHour,
            minute: cleanupMinute,
            second: 0,
            of: now
        ) else {
            return false
        }

        guard now >= cleanupTime else { return false }

        if let lastCleanup = UserDefaults.standard.object(forKey: Self.lastCleanupKey) as? Date,
           calendar.isDate(lastCleanup, inSameDayAs: now) {
            return false
        }

        return true
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
	let dailyCleanupService = DailyCleanupService()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.identifier == DailyCleanupService.notificationId {
            Task {
                await dailyCleanupService.checkAndPerformCleanupIfNeeded()
            }
        }
        // Показываем уведомление даже когда приложение открыто
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == DailyCleanupService.notificationId {
            // Выполняем очистку при нажатии на уведомление
            Task {
                await dailyCleanupService.checkAndPerformCleanupIfNeeded()
            }
        }
        completionHandler()
    }
}

