import SwiftUI
import DesignSystem

public struct LoginView: View {
  @State private var id: String = ""
  @State private var password: String = ""
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 100)
      
      Text("코치코치")
        .font(.pretendardDisplay1)
        .foregroundColor(AppColor.primaryBlue500)
        .padding(.bottom, 60)
      
      VStack(spacing: 24) {
        UnderlinedTextField(
          text: $id,
          placeholder: "아이디를 입력해주세요"
        )
        
        SecureUnderlinedTextField(
          text: $password,
          placeholder: "비밀번호를 입력해주세요"
        )
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
      
      BottomButton(
        title: "로그인",
        style: isFormValid ? .primary : .secondary
      ) {
      }
      .disabled(!isFormValid)
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
      
      HStack(spacing: 12) {
        Button(action: {}) {
          Text("아이디/비밀번호 찾기")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
        }
        
        Rectangle()
          .fill(AppColor.grayscale300)
          .frame(width: 1, height: 12)
        
        Button(action: {}) {
          Text("회원가입")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
        }
      }
      .padding(.bottom, 40)
      
      Spacer()
    }
    .background(Color.white.ignoresSafeArea())
  }
  
  private var isFormValid: Bool {
    !id.isEmpty && !password.isEmpty
  }
}

private struct SecureUnderlinedTextField: View {
  @Binding var text: String
  let placeholder: String
  @FocusState private var isFocused: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      SecureField(
        "",
        text: $text,
        prompt: Text(placeholder)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale400)
      )
      .font(.pretendardBody2)
      .foregroundColor(AppColor.grayscale900)
      .focused($isFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      
      Rectangle()
        .fill(isFocused ? AppColor.primaryBlue500 : AppColor.grayscale300)
        .frame(height: 1)
    }
  }
}

#Preview {
  LoginView()
}
