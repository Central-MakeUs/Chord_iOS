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

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleNotificationsEnabledChanged(_:)),
      name: Notification.Name("NotificationsEnabledChanged"),
      object: nil
    )

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

    let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

    if notificationsEnabled {
      UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
      print("[FCM] Refreshed token: \(fcmToken)")
      NotificationCenter.default.post(name: .fcmTokenDidUpdate, object: nil, userInfo: ["token": fcmToken])
    } else {
      Messaging.messaging().deleteToken { error in
        if let error {
          print("[FCM] Failed to delete token (notifications disabled): \(error)")
        } else {
          print("[FCM] Token deleted (notifications disabled)")
          UserDefaults.standard.removeObject(forKey: "fcmToken")
        }
      }
    }
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

extension AppDelegate {
  @objc func handleNotificationsEnabledChanged(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let isEnabled = userInfo["enabled"] as? Bool else { return }

    if isEnabled {
      Messaging.messaging().token { token, error in
        if let error {
          print("[FCM] Token fetch failed: \(error)")
        } else if let token {
          print("[FCM] Token fetched: \(token)")
        }
      }
    } else {
      Messaging.messaging().deleteToken { error in
        if let error {
          print("[FCM] Token delete failed: \(error)")
        } else {
          print("[FCM] Token deleted - notifications disabled")
        }
      }
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
