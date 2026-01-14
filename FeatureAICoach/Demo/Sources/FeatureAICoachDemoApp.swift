import SwiftUI
import ComposableArchitecture
import FeatureAICoach

@main
struct FeatureAICoachDemoApp: App {
  var body: some Scene {
    WindowGroup {
      AICoachView(
        store: Store(initialState: AICoachFeature.State()) {
          AICoachFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
