import SwiftUI
import ComposableArchitecture
import FeatureMenu

@main
struct FeatureMenuDemoApp: App {
  var body: some Scene {
    WindowGroup {
      MenuView(
        store: Store(initialState: MenuFeature.State()) {
          MenuFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
