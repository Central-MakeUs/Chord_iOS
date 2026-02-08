import ComposableArchitecture
import DataLayer
import Foundation

@Reducer
public struct LoginFeature {
  @Dependency(\.authRepository) var authRepository
  
  @ObservableState
  public struct State: Equatable {
    var id: String = ""
    var password: String = ""
    var showSignUp: Bool = false
    var isErrorAlertPresented: Bool = false
    var errorMessage: String = ""
    var signUp: SignUpFeature.State = SignUpFeature.State()
    
    var isFormValid: Bool {
      !id.isEmpty && !password.isEmpty
    }
    
    public init() {}
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case loginTapped
    case loginSuccess
    case loginFailure(String)
    case signUpTapped
    case signUpDismissed
    case errorAlertDismissed
    case signUp(SignUpFeature.Action)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case loginCompleted(onboardingCompleted: Bool)
    }
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Scope(state: \.signUp, action: \.signUp) {
      SignUpFeature()
    }
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .loginTapped:
        guard state.isFormValid else { return .none }
        
        print("🚀 Login request started for ID: \(state.id)")
        
        return .run { [id = state.id, password = state.password] send in
          do {
            let onboardingCompleted = try await authRepository.login(id, password)
            print("✅ Login API success. OnboardingCompleted: \(onboardingCompleted)")
            await send(.delegate(.loginCompleted(onboardingCompleted: onboardingCompleted)))
          } catch {
            print("❌ Login API failed: \(error)")
            let message = (error as? APIError)?.message ?? "로그인에 실패했습니다."
            await send(.loginFailure(message))
          }
        }
        
      case .loginSuccess:
        return .none
        
      case let .loginFailure(message):
        state.errorMessage = message
        state.isErrorAlertPresented = true
        return .none
        
      case .signUpTapped:
        state.showSignUp = true
        return .none
        
      case .signUpDismissed:
        state.showSignUp = false
        return .none
        
      case .errorAlertDismissed:
        state.isErrorAlertPresented = false
        return .none
        
      case .signUp(.delegate(.signUpCompleted)):
        state.showSignUp = false
        
        return .run { [id = state.signUp.userId, password = state.signUp.password] send in
          do {
            let onboardingCompleted = try await authRepository.login(id, password)
            print("✅ Auto-login after signup success. OnboardingCompleted: \(onboardingCompleted)")
            await send(.delegate(.loginCompleted(onboardingCompleted: onboardingCompleted)))
          } catch {
            print("❌ Auto-login after signup failed: \(error)")
            let message = (error as? APIError)?.message ?? "로그인에 실패했습니다."
            await send(.loginFailure(message))
          }
        }
        
      case .signUp(.delegate(.dismissed)):
        state.showSignUp = false
        return .none
        
      case .signUp:
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}
