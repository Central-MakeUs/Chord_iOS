import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct LoginView: View {
  @Bindable var store: StoreOf<LoginFeature>
  
  public init(store: StoreOf<LoginFeature>) {
    self.store = store
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 100)
      
      Image("LoginLogo", bundle: .main)
        .resizable()
        .scaledToFit()
        .frame(width: 120, height: 33)
        .padding(.bottom, 60)
      
      VStack(spacing: 32) {
        UnderlinedTextField(
          text: $store.id,
          title: "아이디",
          titleColor: AppColor.grayscale900,
          showFocusHighlight: false
        )
        
        UnderlinedTextField(
          text: $store.password,
          title: "비밀번호",
          titleColor: AppColor.grayscale900,
          showFocusHighlight: false,
          isSecure: true
        )
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
      
      BottomButton(
        title: "로그인",
        style: store.isFormValid ? .primary : .secondary
      ) {
        store.send(.loginTapped)
      }
      .disabled(!store.isFormValid)
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
      
      HStack(spacing: 8) {
          
          //TODO: 추후 추가
//        Button(action: {}) {
//          Text("아이디, 비밀번호 찾기")
//            .font(.pretendardCaption1)
//            .foregroundColor(AppColor.grayscale600)
//        }
        
//        Text("|")
//          .font(.pretendardCaption1)
//          .foregroundColor(AppColor.grayscale300)
        
        Button {
          store.send(.signUpTapped)
        } label: {
          Text("회원가입")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
        }
      }
      .padding(.bottom, 40)
      
      Spacer()
    }
    .background(Color.white.ignoresSafeArea())
    .fullScreenCover(
      isPresented: $store.showSignUp,
      onDismiss: { store.send(.signUpDismissed) }
    ) {
      SignUpView(
        store: store.scope(state: \.signUp, action: \.signUp)
      )
    }
    .coachCoachAlert(
      isPresented: $store.isErrorAlertPresented,
      title: store.errorMessage,
      alertType: .oneButton,
      rightButtonTitle: "확인",
      rightButtonAction: {
        store.send(.errorAlertDismissed)
      }
    )
  }
}

#Preview {
  LoginView(
    store: Store(initialState: LoginFeature.State()) {
      LoginFeature()
    }
  )
}
