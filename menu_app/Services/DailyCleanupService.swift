//
//  DailyCleanupService.swift
//  menu_app_ios
//
//  Created on 2024
//

import Foundation
import UserNotifications
import OSLog

class DailyCleanupService {
    static let shared = DailyCleanupService()
    private static let logger = Logger(subsystem: "menu_app_ios", category: "DailyCleanupService")
    
    private init() {}
    
    func scheduleDailyCleanup() {
        let center = UNUserNotificationCenter.current()
        
        // Запрашиваем разрешение на уведомления
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Self.logger.error("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            if granted {
                Self.logger.info("Notification authorization granted")
                self.setupDailyNotification()
            } else {
                Self.logger.warning("Notification authorization denied")
            }
        }
    }
    
    private func setupDailyNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Удаляем предыдущие уведомления
        center.removePendingNotificationRequests(withIdentifiers: ["dailyCleanup"])
        
        // Создаем триггер на 3:00 МСК (00:00 UTC, так как МСК = UTC+3, но нужно проверить)
        // На самом деле 3:00 МСК = 00:00 UTC в зимнее время или 23:00 UTC в летнее
        // Для простоты используем 00:00 UTC (3:00 МСК зимой)
        var dateComponents = DateComponents()
        dateComponents.hour = 0  // 00:00 UTC = 3:00 МСК (зимой)
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Очистка меню"
        content.body = "Выполняется ежедневная очистка меню"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "dailyCleanup", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                Self.logger.error("Error scheduling notification: \(error.localizedDescription)")
            } else {
                Self.logger.info("Daily cleanup notification scheduled")
            }
        }
        
        // Регистрируем обработчик уведомлений
        center.delegate = NotificationDelegate.shared
    }
    
    func performCleanup() async {
        Self.logger.info("Performing daily cleanup")
        do {
            try await APIService.shared.deleteChefAndDishes()
            // Очищаем сохраненного шеф-повара
            UserDefaults.standard.removeObject(forKey: "currentChef")
            Self.logger.info("Daily cleanup completed successfully")
        } catch {
            Self.logger.error("Error during daily cleanup: \(error.localizedDescription)")
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Показываем уведомление даже когда приложение открыто
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "dailyCleanup" {
            // Выполняем очистку при нажатии на уведомление
            Task {
                await DailyCleanupService.shared.performCleanup()
            }
        }
        completionHandler()
    }
}

