import ComposableArchitecture
import FeatureOnboarding
import FeatureMenuRegistration
import Foundation

@Reducer
struct AppFeature {
  struct State: Equatable {
    var hasCompletedOnboarding: Bool
    var hasSeenMenuRegistrationStart: Bool
    var isShowingMenuRegistration = false
    var onboarding = OnboardingFeature.State()
    var menuRegistrationStart = MenuRegistrationStartFeature.State()
    var menuRegistration: MenuRegistrationFeature.State
    var main = MainFeature.State()

    init(
      hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding),
      hasSeenMenuRegistrationStart: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenMenuRegistrationStart),
      menuRegistration: MenuRegistrationFeature.State = MenuRegistrationFeature.State()
    ) {
      print("🟣 AppFeature.State init START")
      print("🟣 hasCompletedOnboarding: \(hasCompletedOnboarding)")
      print("🟣 hasSeenMenuRegistrationStart: \(hasSeenMenuRegistrationStart)")
      self.hasCompletedOnboarding = hasCompletedOnboarding
      self.hasSeenMenuRegistrationStart = hasSeenMenuRegistrationStart
      self.menuRegistration = menuRegistration
      print("🟣 AppFeature.State init DONE")
    }
  }

  enum Action: Equatable {
    case onboarding(OnboardingFeature.Action)
    case menuRegistrationStart(MenuRegistrationStartFeature.Action)
    case menuRegistration(MenuRegistrationFeature.Action)
    case main(MainFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.onboarding, action: \.onboarding) {
      OnboardingFeature()
    }

    Scope(state: \.menuRegistrationStart, action: \.menuRegistrationStart) {
      MenuRegistrationStartFeature()
    }

    Scope(state: \.menuRegistration, action: \.menuRegistration) {
      MenuRegistrationFeature()
    }

    Scope(state: \.main, action: \.main) {
      MainFeature()
    }

    Reduce { state, action in
      switch action {
      case .onboarding(.delegate(.finished)):
        state.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        return .none

      case .menuRegistrationStart(.startTapped):
        state.isShowingMenuRegistration = true
        return .none

      case .menuRegistrationStart(.skipTapped):
        state.hasSeenMenuRegistrationStart = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenMenuRegistrationStart)
        return .none

      case .menuRegistration(.backTapped):
        state.isShowingMenuRegistration = false
        return .none

      case .menuRegistration(.completeTapped):
        state.hasSeenMenuRegistrationStart = true
        state.isShowingMenuRegistration = false
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenMenuRegistrationStart)
        return .none

      case .onboarding,
           .menuRegistrationStart,
           .menuRegistration,
           .main:
        return .none
      }
    }
  }
}

private enum UserDefaultsKeys {
  static let hasCompletedOnboarding = "hasCompletedOnboarding"
  static let hasSeenMenuRegistrationStart = "hasSeenMenuRegistrationStart"
}
