import SwiftUI
import ComposableArchitecture
import FeatureOnboarding

@main
struct FeatureOnboardingDemoApp: App {
  var body: some Scene {
    WindowGroup {
      OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
          OnboardingFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
