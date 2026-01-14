import SwiftUI
import ComposableArchitecture
import FeatureIngredients

@main
struct FeatureIngredientsDemoApp: App {
  var body: some Scene {
    WindowGroup {
      IngredientsView(
        store: Store(initialState: IngredientsFeature.State()) {
          IngredientsFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
