import ComposableArchitecture
import DataLayer
import Foundation

@Reducer
public struct SignUpFeature {
  @Dependency(\.authRepository) var authRepository
  public enum Step: Equatable {
    case form
    case complete
  }
  
  @ObservableState
  public struct State: Equatable {
    var step: Step = .form
    var userId: String = ""
    var password: String = ""
    var passwordConfirm: String = ""
    var isPasswordVisible: Bool = false
    var isPasswordConfirmVisible: Bool = false
    
    var userIdError: String? = nil
    var passwordConfirmError: String? = nil
    var isCheckingUserId: Bool = false
    var isUserIdAvailable: Bool? = nil
    var isErrorAlertPresented: Bool = false
    var errorMessage: String = ""
    
    public init() {}
    
    // MARK: - Computed Properties
    
    var isUserIdValid: Bool {
      userId.count >= 3
    }
    
    var isPasswordLengthValid: Bool {
      password.count >= 8
    }
    
    var isPasswordComplexityValid: Bool {
      let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
      let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
      let hasSpecial = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
      
      let validTypes = [hasLetter, hasNumber, hasSpecial].filter { $0 }.count
      return validTypes >= 2
    }
    
    var isPasswordConfirmValid: Bool {
      !passwordConfirm.isEmpty && password == passwordConfirm
    }
    
    var isFormValid: Bool {
      isUserIdValid &&
      isPasswordLengthValid &&
      isPasswordComplexityValid &&
      isPasswordConfirmValid &&
      userIdError == nil &&
      isUserIdAvailable == true
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case backTapped
    case signUpTapped
    case togglePasswordVisibility
    case togglePasswordConfirmVisibility
    case userIdChanged(String)
    case passwordConfirmChanged(String)
    case checkUserIdAvailability
    case userIdCheckResponse(Bool)
    case signUpSuccess
    case signUpFailure(String)
    case errorAlertDismissed
    case completionTimerFired
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case signUpCompleted
      case dismissed
    }
  }
  
  private enum CancelID {
    case userIdCheck
    case completionTimer
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .backTapped:
        return .send(.delegate(.dismissed))
        
      case let .userIdChanged(userId):
        state.userId = userId
        state.userIdError = nil
        state.isUserIdAvailable = nil
        
        if userId.count < 3 && !userId.isEmpty {
          state.userIdError = "3자 이상 입력해주세요"
          return .none
        }
        
        guard userId.count >= 3 else { return .none }
        
        return .run { send in
          try await Task.sleep(for: .milliseconds(500))
          await send(.checkUserIdAvailability)
        }
        .cancellable(id: CancelID.userIdCheck, cancelInFlight: true)
        
      case .checkUserIdAvailability:
        state.isCheckingUserId = true
        // TODO: 실제 API 호출로 교체
        return .run { [userId = state.userId] send in
          try await Task.sleep(for: .milliseconds(300))
          let isAvailable = userId != "qwer1"
          await send(.userIdCheckResponse(isAvailable))
        }
        
      case let .userIdCheckResponse(isAvailable):
        state.isCheckingUserId = false
        state.isUserIdAvailable = isAvailable
        if !isAvailable {
          state.userIdError = "이미 사용 중인 아이디입니다"
        }
        return .none
        
      case let .passwordConfirmChanged(confirm):
        state.passwordConfirm = confirm
        if !confirm.isEmpty && state.password != confirm {
          state.passwordConfirmError = "동일한 비밀번호를 입력해주세요"
        } else {
          state.passwordConfirmError = nil
        }
        return .none
        
      case .togglePasswordVisibility:
        state.isPasswordVisible.toggle()
        return .none
        
      case .togglePasswordConfirmVisibility:
        state.isPasswordConfirmVisible.toggle()
        return .none
        
      case .signUpTapped:
        guard state.isFormValid else { return .none }
        
        return .run { [userId = state.userId, password = state.password] send in
          do {
            try await authRepository.signUp(userId, password)
            await send(.signUpSuccess)
          } catch let error as APIError {
            print("❌ SignUp API failed: \(error)")
            let message: String
            switch error {
            case .serverError(_, let errorMessage):
              message = errorMessage
            default:
              message = "회원가입에 실패했습니다\n잠시 후 다시 시도해주세요"
            }
            await send(.signUpFailure(message))
          } catch {
            await send(.signUpFailure("회원가입에 실패했습니다\n잠시 후 다시 시도해주세요"))
          }
        }
        
      case .signUpSuccess:
        state.step = .complete
        return .run { send in
          try await Task.sleep(for: .seconds(1))
          await send(.completionTimerFired)
        }
        .cancellable(id: CancelID.completionTimer)
        
      case let .signUpFailure(message):
        state.errorMessage = message
        state.isErrorAlertPresented = true
        return .none
      
      case .errorAlertDismissed:
        state.isErrorAlertPresented = false
        return .none
        
      case .completionTimerFired:
        return .send(.delegate(.signUpCompleted))
        
      case .delegate:
        return .none
      }
    }
  }
}
