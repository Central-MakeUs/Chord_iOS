import SwiftUI

struct AppEntryView: View {
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
  @AppStorage("hasSeenMenuRegistrationStart") private var hasSeenMenuRegistrationStart = false
  @State private var isShowingMenuRegistration = false

  var body: some View {
    if !hasCompletedOnboarding {
      OnboardingView {
        hasCompletedOnboarding = true
      }
    } else if !hasSeenMenuRegistrationStart {
      if isShowingMenuRegistration {
        MenuRegistrationView(
          onBack: { isShowingMenuRegistration = false },
          onComplete: { hasSeenMenuRegistrationStart = true }
        )
      } else {
        MenuRegistrationStartView(
          onSkip: { hasSeenMenuRegistrationStart = true },
          onStart: { isShowingMenuRegistration = true }
        )
      }
    } else {
      MainView()
    }
  }
}

#Preview {
  AppEntryView()
    .environmentObject(AppRouter())
    .environmentObject(MenuRouter())
    .environmentObject(InventoryRouter())
    .environmentObject(SettingsRouter())
    .environment(\.colorScheme, .light)
}
