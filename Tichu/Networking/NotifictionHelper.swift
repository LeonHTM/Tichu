//
//  NotificationHelper.swift
//  Tichu
//
//  Created by Leon on 18.05.2026.
//

import SwiftUI
import UserNotifications

@MainActor
class CustomAppDelegate: NSObject, UIApplicationDelegate {
    var app: TichuApp?
    var onDeviceToken: ((String) -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs token:", stringifiedToken)
        onDeviceToken?(stringifiedToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications:", error)
    }
}

extension CustomAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("Notification tapped:", response.notification.request.content.title)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
}
