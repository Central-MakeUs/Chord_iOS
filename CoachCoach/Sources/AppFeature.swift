import ComposableArchitecture
import FeatureOnboarding
import FeatureMenuRegistration
import Foundation
import DataLayer

@Reducer
struct AppFeature {
  @Dependency(\.authRepository) var authRepository
  @Dependency(\.menuRepository) var menuRepository
  @Dependency(\.userRepository) var userRepository
  
  struct State: Equatable {
    enum AppStatus: Equatable {
      case loading
      case unauthenticated
      case onboarding
      case menuRegistration
      case authenticated
    }
    
    var status: AppStatus = .loading
    var isLoggedIn: Bool
    var hasCompletedOnboarding: Bool
    var isShowingMenuRegistration = false
    var login = LoginFeature.State()
    var onboarding = OnboardingFeature.State()
    var menuRegistration: MenuRegistrationFeature.State
    var main = MainFeature.State()

    init(
      isLoggedIn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isLoggedIn),
      hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding),
      menuRegistration: MenuRegistrationFeature.State = MenuRegistrationFeature.State()
    ) {
      self.isLoggedIn = isLoggedIn
      self.hasCompletedOnboarding = hasCompletedOnboarding
      self.menuRegistration = menuRegistration
      
      // Initialize status based on stored values, but prefer loading for proper async check
      // We will re-verify everything in onAppear
      self.status = .loading
    }
  }

  enum Action: Equatable {
    case onAppear
    case autoLoginResult(Result<Void, Error>)
    case logout
    case logoutResult(Result<Void, Error>)
    case withdrawal
    case withdrawalResult(Result<Void, Error>)
    case login(LoginFeature.Action)
    case onboarding(OnboardingFeature.Action)
    case menuRegistration(MenuRegistrationFeature.Action)
    case menuCheckCompleted(hasMenu: Bool)
    case main(MainFeature.Action)
    
    static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case let (.menuCheckCompleted(l), .menuCheckCompleted(r)): return l == r
      case (.onAppear, .onAppear): return true
      case (.autoLoginResult(.success), .autoLoginResult(.success)): return true
      case (.autoLoginResult(.failure), .autoLoginResult(.failure)): return true
      case (.logout, .logout): return true
      case (.logoutResult(.success), .logoutResult(.success)): return true
      case (.logoutResult(.failure), .logoutResult(.failure)): return true
      case (.withdrawal, .withdrawal): return true
      case (.withdrawalResult(.success), .withdrawalResult(.success)): return true
      case (.withdrawalResult(.failure), .withdrawalResult(.failure)): return true
      case let (.login(l), .login(r)): return l == r
      case let (.onboarding(l), .onboarding(r)): return l == r
      case let (.menuRegistration(l), .menuRegistration(r)): return l == r
      case let (.main(l), .main(r)): return l == r
      default: return false
      }
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.login, action: \.login) {
      LoginFeature()
    }

    Scope(state: \.onboarding, action: \.onboarding) {
      OnboardingFeature()
    }

    Scope(state: \.menuRegistration, action: \.menuRegistration) {
      MenuRegistrationFeature()
    }

    Scope(state: \.main, action: \.main) {
      MainFeature()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        print("🚀 [App] onAppear - Starting checks...")
        state.status = .loading
        
        // If not logged in locally, go straight to login
        guard state.isLoggedIn else {
          print("ℹ️ [App] No local login session. Going to Login.")
          return .run { send in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await send(.autoLoginResult(.failure(APIError.networkError("Not logged in"))))
          }
        }
        
        print("🔄 [App] Attempting auto-login (refresh token)...")
        return .run { send in
          do {
            async let refreshTask: Void = authRepository.refresh()
            async let minimumDelay: Void = Task.sleep(nanoseconds: 1_500_000_000)
            
            let _ = try await (refreshTask, minimumDelay)
            print("✅ [App] Auto-login successful!")
            await send(.autoLoginResult(.success(())))
          } catch {
            print("❌ [App] Auto-login failed!")
            await send(.autoLoginResult(.failure(error)))
          }
        }
      
      case .autoLoginResult(.success):
        state.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isLoggedIn)
        
        // If logged in but onboarding NOT completed
        if !state.hasCompletedOnboarding {
             state.status = .onboarding
             return .none
        }
        
        // If logged in AND onboarding completed -> Check Menus
        return .run { send in
            do {
                let menus = try await menuRepository.fetchMenuItems(nil)
                let hasMenu = !menus.isEmpty
                print("🔄 [App] Menu check: hasMenu = \(hasMenu)")
                await send(.menuCheckCompleted(hasMenu: hasMenu))
            } catch {
                print("❌ [App] Failed to fetch menus: \(error)")
                // Fallback: Assume menus exist to avoid blocking, or retry?
                // Safe default: Go to Main
                await send(.menuCheckCompleted(hasMenu: true))
            }
        }
      
      case .autoLoginResult(.failure):
        state.isLoggedIn = false
        state.status = .unauthenticated
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isLoggedIn)
        return .none
      
      case .main(.logoutTapped):
        return .send(.logout)

      case .main(.withdrawalTapped):
        return .send(.withdrawal)

      case .logout:
        return .run { send in
          do {
            try await authRepository.logout()
            print("✅ Logout successful")
            await send(.logoutResult(.success(())))
          } catch {
            print("❌ Logout failed: \(error)")
            await send(.logoutResult(.failure(error)))
          }
        }

      case .logoutResult(.success):
        state.isLoggedIn = false
        state.hasCompletedOnboarding = false
        state.status = .unauthenticated
        state.isShowingMenuRegistration = false

        // Clear navigation + local view states
        state.main = MainFeature.State()
        state.login = LoginFeature.State()
        state.onboarding = OnboardingFeature.State()
        state.menuRegistration = MenuRegistrationFeature.State()

        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isLoggedIn)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        return .none
      
      case .logoutResult(.failure):
        return .none

      case .withdrawal:
        return .run { send in
          do {
            try await userRepository.withdraw()
            try await authRepository.logout()
            print("✅ Withdrawal successful")
            await send(.withdrawalResult(.success(())))
          } catch {
            print("❌ Withdrawal failed: \(error)")
            await send(.withdrawalResult(.failure(error)))
          }
        }

      case .withdrawalResult(.success):
        return .send(.logoutResult(.success(())))

      case .withdrawalResult(.failure):
        return .none

      case .menuCheckCompleted(let hasMenu):
        if !hasMenu {
          state.status = .menuRegistration
          state.isShowingMenuRegistration = true
        } else {
          state.status = .authenticated
        }
        return .none

      case .login(.delegate(.loginCompleted(let onboardingCompleted))):
        state.isLoggedIn = true
        state.hasCompletedOnboarding = onboardingCompleted
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isLoggedIn)
        UserDefaults.standard.set(onboardingCompleted, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        
        if !onboardingCompleted {
          state.status = .onboarding
          return .none
        } else {
          // Check menu
          return .run { send in
            do {
              let menus = try await menuRepository.fetchMenuItems(nil)
              let hasMenu = !menus.isEmpty
              await send(.menuCheckCompleted(hasMenu: hasMenu))
            } catch {
              await send(.menuCheckCompleted(hasMenu: true))
            }
          }
        }

      case .onboarding(.delegate(.finished)):
        state.hasCompletedOnboarding = true
        state.status = .menuRegistration
        state.isShowingMenuRegistration = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        return .none

      case .menuRegistration(.delegate(.menuCreated)):
        state.status = .authenticated
        state.isShowingMenuRegistration = false
        return .none
        
      case .menuRegistration(.delegate(.dismissed)):
        state.status = state.hasCompletedOnboarding ? .authenticated : .onboarding
        state.isShowingMenuRegistration = false
        return .none

      case .login,
           .onboarding,
           .menuRegistration,
           .main:
        return .none
      }
    }
  }
}

private enum UserDefaultsKeys {
  static let isLoggedIn = "isLoggedIn"
  static let hasCompletedOnboarding = "hasCompletedOnboarding"
}
