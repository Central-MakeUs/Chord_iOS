import ComposableArchitecture
import DataLayer
import Foundation

@Reducer
public struct LoginFeature: Sendable {
  @Dependency(\.authRepository) var authRepository
  
  @ObservableState
  public struct State: Equatable {
    var id: String = ""
    var password: String = ""
    var showSignUp: Bool = false
    var loginIdErrorMessage: String? = nil
    var passwordErrorMessage: String? = nil
    var showAlert: Bool = false
    var alertMessage: String = ""
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
    case loginValidationFailure([String: String], fallbackMessage: String)
    case alertDismissed
    case signUpTapped
    case signUpDismissed
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
        state.loginIdErrorMessage = nil
        state.passwordErrorMessage = nil
        state.showAlert = false
        return .none
        
      case .loginTapped:
        guard state.isFormValid else { return .none }
        state.loginIdErrorMessage = nil
        state.passwordErrorMessage = nil
        
        print("🚀 Login request started for ID: \(state.id)")
        
        return .run { [id = state.id, password = state.password] send in
          do {
            let onboardingCompleted = try await authRepository.login(id, password)
            print("✅ Login API success. OnboardingCompleted: \(onboardingCompleted)")
            await send(.delegate(.loginCompleted(onboardingCompleted: onboardingCompleted)))
          } catch let validationError as APIFieldValidationError {
            print("❌ Login API validation failed: \(validationError)")
            await send(
              .loginValidationFailure(
                validationError.fieldErrors,
                fallbackMessage: validationError.message
              )
            )
          } catch {
            print("❌ Login API failed: \(error)")
            let message = (error as? APIError)?.message ?? "로그인에 실패했습니다."
            await send(.loginFailure(message))
          }
        }
        
      case .loginSuccess:
        return .none
        
      case let .loginFailure(message):
        state.showAlert = true
        state.alertMessage = message
        return .none

      case let .loginValidationFailure(fieldErrors, fallbackMessage):
        let loginIdError = fieldErrors["loginId"]
        let passwordError = fieldErrors["password"]

        if loginIdError == nil && passwordError == nil {
          state.showAlert = true
          state.alertMessage = fallbackMessage
        } else {
          state.loginIdErrorMessage = loginIdError
          state.passwordErrorMessage = passwordError
        }
        return .none

      case .alertDismissed:
        state.showAlert = false
        state.alertMessage = ""
        return .none
        
      case .signUpTapped:
        state.showSignUp = true
        return .none
        
      case .signUpDismissed:
        state.showSignUp = false
        state.signUp = SignUpFeature.State()
        return .none
        
      case .signUp(.delegate(.signUpCompleted)):
        let id = state.signUp.userId
        let password = state.signUp.password
        state.showSignUp = false
        state.signUp = SignUpFeature.State()

        return .run { send in
          do {
            let onboardingCompleted = try await authRepository.login(id, password)
            print("✅ Auto-login after signup success. OnboardingCompleted: \(onboardingCompleted)")
            await send(.delegate(.loginCompleted(onboardingCompleted: onboardingCompleted)))
          } catch let validationError as APIFieldValidationError {
            print("❌ Auto-login after signup validation failed: \(validationError)")
            await send(
              .loginValidationFailure(
                validationError.fieldErrors,
                fallbackMessage: validationError.message
              )
            )
          } catch {
            print("❌ Auto-login after signup failed: \(error)")
            let message = (error as? APIError)?.message ?? "로그인에 실패했습니다."
            await send(.loginFailure(message))
          }
        }
        
      case .signUp(.delegate(.dismissed)):
        state.showSignUp = false
        state.signUp = SignUpFeature.State()
        return .none
        
      case .signUp:
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}
