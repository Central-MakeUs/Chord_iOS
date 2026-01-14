import SwiftUI
import ComposableArchitecture
import FeatureMenuRegistration

@main
struct FeatureMenuRegistrationDemoApp: App {
  var body: some Scene {
    WindowGroup {
      MenuRegistrationView(
        store: Store(initialState: MenuRegistrationFeature.State()) {
          MenuRegistrationFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
