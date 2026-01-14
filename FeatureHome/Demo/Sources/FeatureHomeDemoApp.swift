import SwiftUI
import ComposableArchitecture
import FeatureHome

@main
struct FeatureHomeDemoApp: App {
  var body: some Scene {
    WindowGroup {
      HomeView(
        store: Store(initialState: HomeFeature.State()) {
          HomeFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
