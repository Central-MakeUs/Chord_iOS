import SwiftUI
import ComposableArchitecture
import FeatureMenuRegistration
import FeatureOnboarding

struct AppEntryView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      if !viewStore.hasCompletedOnboarding {
        OnboardingView(
          store: store.scope(state: \.onboarding, action: \.onboarding)
        )
      } else if !viewStore.hasSeenMenuRegistrationStart {
        if viewStore.isShowingMenuRegistration {
          MenuRegistrationView(
            store: store.scope(state: \.menuRegistration, action: \.menuRegistration)
          )
        } else {
          MenuRegistrationStartView(
            store: store.scope(
              state: \.menuRegistrationStart,
              action: \.menuRegistrationStart
            )
          )
        }
      } else {
        MainView(store: store.scope(state: \.main, action: \.main))
      }
    }
  }
}

#Preview {
  AppEntryView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
