import SwiftUI
import ComposableArchitecture
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private let appStore = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    let rootController = UIHostingController(
      rootView: AppEntryView(store: appStore)
        .environment(\.colorScheme, .light)
    )
    rootController.view.backgroundColor = .white
    window.backgroundColor = .white
    window.rootViewController = rootController

    let dismissKeyboardTap = UITapGestureRecognizer(
      target: self,
      action: #selector(handleGlobalTapToDismissKeyboard)
    )
    dismissKeyboardTap.cancelsTouchesInView = false
    window.addGestureRecognizer(dismissKeyboardTap)

    self.window = window
    window.makeKeyAndVisible()
  }

  @objc
  private func handleGlobalTapToDismissKeyboard() {
    window?.endEditing(true)
  }
}
