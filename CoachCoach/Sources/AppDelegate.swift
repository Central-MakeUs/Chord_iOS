import FirebaseCore
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
      UserDefaults.standard.set(deviceId, forKey: "deviceId")
    }

    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
      if let error {
        print("[FCM] Notification authorization failed: \(error.localizedDescription)")
      }
    }

    application.registerForRemoteNotifications()

    return true
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    requestCurrentFCMToken()
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[FCM] APNs registration failed: \(error.localizedDescription)")
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken else { return }
    UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    print("[FCM] Refreshed token: \(fcmToken)")
    NotificationCenter.default.post(name: .fcmTokenDidUpdate, object: nil, userInfo: ["token": fcmToken])
  }
}

private extension AppDelegate {
  func requestCurrentFCMToken() {
    Messaging.messaging().token { token, error in
      if let error {
        print("[FCM] Failed to fetch token: \(error.localizedDescription)")
        return
      }

      guard let token else { return }
      UserDefaults.standard.set(token, forKey: "fcmToken")
      print("[FCM] Initial token: \(token)")
      NotificationCenter.default.post(name: .fcmTokenDidUpdate, object: nil, userInfo: ["token": token])
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    [.banner, .list, .sound]
  }
}

extension Notification.Name {
  static let fcmTokenDidUpdate = Notification.Name("fcmTokenDidUpdate")
}
