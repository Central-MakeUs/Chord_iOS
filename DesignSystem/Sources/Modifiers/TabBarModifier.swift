import SwiftUI
import UIKit

public extension View {
  func hideTabBar(_ hide: Bool) -> some View {
    modifier(TabBarHiderModifier(hide: hide))
  }
}

private struct TabBarHiderModifier: ViewModifier {
  let hide: Bool
  
  func body(content: Content) -> some View {
    content
      .background(TabBarHider(hide: hide))
      .background(AppearanceHandler(
        hide: hide,
        onAppear: { setTabBarHidden(hide) }
      ))
  }
}

private struct TabBarHider: UIViewRepresentable {
  let hide: Bool
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.isUserInteractionEnabled = false
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    setTabBarHidden(hide, from: uiView)
  }
}

private func setTabBarHidden(_ hidden: Bool, from view: UIView? = nil) {
  let tabBar: UITabBar?
  
  if let view = view {
    tabBar = findTabBar(from: view)
  } else {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    tabBar = findTabBarInSubviews(of: window)
  }
  
  guard let tabBar = tabBar else { return }
  
  let screenHeight = UIScreen.main.bounds.height
  let tabBarHeight = tabBar.frame.height

  if hidden {
    tabBar.frame.origin.y = screenHeight + 100
  } else {
    tabBar.frame.origin.y = screenHeight - tabBarHeight
  }
}

private func findTabBar(from view: UIView) -> UITabBar? {
  var responder: UIResponder? = view
  while let r = responder {
    if let tabBarController = r as? UITabBarController {
      return tabBarController.tabBar
    }
    responder = r.next
  }
  
  guard let window = view.window else { return nil }
  return findTabBarInSubviews(of: window)
}

private func findTabBarInSubviews(of view: UIView) -> UITabBar? {
  if let tabBar = view as? UITabBar {
    return tabBar
  }
  for subview in view.subviews {
    if let found = findTabBarInSubviews(of: subview) {
      return found
    }
  }
  return nil
}

private struct AppearanceHandler: UIViewControllerRepresentable {
  let hide: Bool
  let onAppear: () -> Void
  
  func makeUIViewController(context: Context) -> AppearanceViewController {
    AppearanceViewController(hide: hide, onAppear: onAppear)
  }
  
  func updateUIViewController(_ uiViewController: AppearanceViewController, context: Context) {
    uiViewController.hide = hide
  }
}

private class AppearanceViewController: UIViewController {
  var hide: Bool
  let onAppear: () -> Void
  
  init(hide: Bool, onAppear: @escaping () -> Void) {
    self.hide = hide
    self.onAppear = onAppear
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if hide {
      onAppear()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !hide {
      onAppear()
    }
  }
}
