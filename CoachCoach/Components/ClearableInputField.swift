import SwiftUI

struct ClearableInputField: View {
  @Binding var text: String
  let placeholder: String
  let height: CGFloat
  let backgroundColor: Color

  @FocusState private var isFocused: Bool

  init(
    text: Binding<String>,
    placeholder: String,
    height: CGFloat = 52,
    backgroundColor: Color = .clear
  ) {
    _text = text
    self.placeholder = placeholder
    self.height = height
    self.backgroundColor = backgroundColor
  }

  var body: some View {
    HStack(spacing: 12) {
      TextField(
        "",
        text: $text,
        prompt: Text(placeholder)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale400)
      )
      .font(.pretendardBody2)
      .foregroundColor(textColor)
      .focused($isFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)

      if !text.isEmpty {
        Button(action: { text = "" }) {
          Image.cancelRoundedIcon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
            .scaledToFit()
            .frame(width: 18, height: 18)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 16)
    .frame(height: height)
    .background(
      RoundedRectangle(cornerRadius: height / 2)
        .fill(backgroundColor)
    )
    .overlay(
      RoundedRectangle(cornerRadius: height / 2)
        .stroke(borderColor, lineWidth: 1)
    )
  }

  private var borderColor: Color {
    if isFocused {
      return AppColor.primaryBlue500
    }
    return text.isEmpty ? AppColor.grayscale300 : AppColor.grayscale700
  }

  private var textColor: Color {
    if isFocused {
      return AppColor.grayscale900
    }
    return text.isEmpty ? AppColor.grayscale400 : AppColor.grayscale700
  }
}

#Preview {
  VStack(spacing: 12) {
    ClearableInputField(text: .constant(""), placeholder: "다른 이름 입력", height: 47)
    ClearableInputField(text: .constant("돌체라떼"), placeholder: "다른 이름 입력", height: 47)
  }
  .padding()
  .background(AppColor.grayscale100)
}
