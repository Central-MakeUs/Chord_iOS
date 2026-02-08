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
              LoginView(
                store: Store(initialState: LoginFeature.State()) {
                  LoginFeature()
                }
              )
            }
            NavigationLink("회원가입") {
              SignUpView(
                store: Store(initialState: SignUpFeature.State()) {
                  SignUpFeature()
                }
              )
            }
            NavigationLink("가입완료") {
              SignUpCompleteView()
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
