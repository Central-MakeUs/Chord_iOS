import SwiftUI
import ComposableArchitecture
import FeatureMenuRegistration
import FeatureOnboarding

struct AppEntryView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Group {
        switch viewStore.status {
        case .loading:
          SplashView()
        case .unauthenticated:
          LoginView(store: store.scope(state: \.login, action: \.login))
        case .onboarding:
          OnboardingView(store: store.scope(state: \.onboarding, action: \.onboarding))
        case .menuRegistration:
          MenuRegistrationView(store: store.scope(state: \.menuRegistration, action: \.menuRegistration))
        case .authenticated:
          MainView(store: store.scope(state: \.main, action: \.main))
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
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
