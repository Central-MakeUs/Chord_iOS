import SwiftUI
import ComposableArchitecture

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
    window.rootViewController = UIHostingController(
      rootView: AppEntryView(store: appStore)
        .environment(\.colorScheme, .light)
    )
    self.window = window
    window.makeKeyAndVisible()
  }
}
