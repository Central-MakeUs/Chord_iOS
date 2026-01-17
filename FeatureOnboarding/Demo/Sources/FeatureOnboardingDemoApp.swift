import SwiftUI
import ComposableArchitecture
import FeatureOnboarding

@main
struct FeatureOnboardingDemoApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        List {
          Section("Auth") {
            NavigationLink("스플래시") {
              SplashView()
            }
            NavigationLink("로그인") {
              LoginView()
            }
          }
          Section("Onboarding") {
            NavigationLink("온보딩 플로우") {
              OnboardingView(
                store: Store(initialState: OnboardingFeature.State()) {
                  OnboardingFeature()
                }
              )
            }
          }
        }
        .navigationTitle("Onboarding Demo")
      }
      .environment(\.colorScheme, .light)
    }
  }
}
