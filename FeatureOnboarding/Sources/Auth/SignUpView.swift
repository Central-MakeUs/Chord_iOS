import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SignUpView: View {
  @Bindable var store: StoreOf<SignUpFeature>
  @Environment(\.dismiss) private var dismiss
  
  public init(store: StoreOf<SignUpFeature>) {
    self.store = store
  }
  
  public var body: some View {
    Group {
      switch store.step {
      case .form:
        formView
      case .complete:
        SignUpCompleteView()
      }
    }
    .onChange(of: store.step) { _, newStep in
      if newStep == .complete {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          dismiss()
        }
      }
    }
  }
  
  private var formView: some View {
    VStack(spacing: 0) {
      navigationBar
      
      ScrollView {
        VStack(alignment: .leading, spacing: 40) {
          userIdSection
          passwordSection
          passwordConfirmSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
      }
      
      Spacer()
      
      BottomButton(
        title: "가입하기",
        style: store.isFormValid ? .primary : .secondary
      ) {
        store.send(.signUpTapped)
      }
      .disabled(!store.isFormValid)
      .padding(.horizontal, 20)
      .padding(.bottom, 34)
    }
    .background(Color.white.ignoresSafeArea())
    .coachCoachAlert(
      isPresented: $store.isErrorAlertPresented,
      title: store.errorMessage,
      content: "",
      alertType: .oneButton,
      rightButtonTitle: "확인",
      rightButtonAction: {
        store.send(.errorAlertDismissed)
      }
    )
  }
  
  private var navigationBar: some View {
    HStack {
      Button {
        dismiss()
      } label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(AppColor.grayscale900)
      }
      
      Spacer()
      
      Text("회원가입")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
      
      Spacer()
      
      Color.clear
        .frame(width: 20, height: 20)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  private var userIdSection: some View {
    UnderlinedTextField(
      text: Binding(
        get: { store.userId },
        set: { store.send(.userIdChanged($0)) }
      ),
      title: "아이디",
      placeholder: "아이디 입력",
      errorMessage: store.userIdError,
      showFocusHighlight: false
    )
  }
  
  private var passwordSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("비밀번호")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)
      
      HStack {
        Group {
          if store.isPasswordVisible {
            TextField(
              "",
              text: $store.password,
              prompt: Text("비밀번호 입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale500)
            )
          } else {
            SecureField(
              "",
              text: $store.password,
              prompt: Text("비밀번호 입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale500)
            )
          }
        }
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        
        Button {
          store.send(.togglePasswordVisibility)
        } label: {
          Image(systemName: store.isPasswordVisible ? "eye" : "eye.slash")
            .foregroundColor(AppColor.grayscale500)
        }
      }
      
      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
      
      VStack(alignment: .leading, spacing: 4) {
        ValidationCheckRow(
          text: "8자리 이상",
          isValid: store.isPasswordLengthValid
        )
        ValidationCheckRow(
          text: "영문 대소문자, 숫자, 특수문자 중 2가지 이상 포함",
          isValid: store.isPasswordComplexityValid
        )
      }
    }
  }
  
  private var passwordConfirmSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("비밀번호 확인")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)
      
      HStack {
        Group {
          if store.isPasswordConfirmVisible {
            TextField(
              "",
              text: Binding(
                get: { store.passwordConfirm },
                set: { store.send(.passwordConfirmChanged($0)) }
              ),
              prompt: Text("비밀번호 재입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale500)
            )
          } else {
            SecureField(
              "",
              text: Binding(
                get: { store.passwordConfirm },
                set: { store.send(.passwordConfirmChanged($0)) }
              ),
              prompt: Text("비밀번호 재입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale500)
            )
          }
        }
        .font(.pretendardSubtitle2)
        .foregroundColor(store.passwordConfirmError != nil ? AppColor.error : AppColor.grayscale900)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        
        Button {
          store.send(.togglePasswordConfirmVisibility)
        } label: {
          Image(systemName: store.isPasswordConfirmVisible ? "eye" : "eye.slash")
            .foregroundColor(AppColor.grayscale500)
        }
      }
      
      Rectangle()
        .fill(store.passwordConfirmError != nil ? AppColor.error : AppColor.grayscale300)
        .frame(height: 1)
      
      if let error = store.passwordConfirmError {
        Text(error)
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.error)
      }
    }
  }
}

private struct ValidationCheckRow: View {
  let text: String
  let isValid: Bool
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "checkmark")
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(isValid ? AppColor.primaryBlue500 : AppColor.grayscale400)
      
      Text(text)
        .font(.pretendardCaption2)
        .foregroundColor(isValid ? AppColor.primaryBlue500 : AppColor.grayscale500)
    }
  }
}

#Preview {
  SignUpView(
    store: Store(initialState: SignUpFeature.State()) {
      SignUpFeature()
    }
  )
}
