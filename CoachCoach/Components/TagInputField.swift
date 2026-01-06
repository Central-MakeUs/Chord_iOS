import SwiftUI

struct TagInputField: View {
  @Binding var text: String
  let placeholder: String
  let height: CGFloat
  let backgroundColor: Color
  let onTapAdd: (() -> Void)?

  @FocusState private var isFocused: Bool

  init(
    text: Binding<String>,
    placeholder: String,
    height: CGFloat = 52,
    backgroundColor: Color = AppColor.grayscale100,
    onTapAdd: (() -> Void)? = nil
  ) {
    _text = text
    self.placeholder = placeholder
    self.height = height
    self.backgroundColor = backgroundColor
    self.onTapAdd = onTapAdd
  }

  var body: some View {
    HStack(spacing: 12) {
      TextField(
        "",
        text: $text,
        prompt: Text(placeholder)
          .font(.pretendardBody1)
          .foregroundColor(AppColor.grayscale400)
      )
      .font(.pretendardBody1)
      .foregroundColor(textColor)
      .focused($isFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)

      Button(action: { onTapAdd?() }) {
        Image.plusIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale700)
          .frame(width: 16, height: 16)
      }
      .buttonStyle(.plain)
      .disabled(onTapAdd == nil)
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
    TagInputField(text: .constant(""), placeholder: "메뉴 태그 직접 작성하기")
    TagInputField(text: .constant("입력 완료했을 경우"), placeholder: "메뉴 태그 직접 작성하기")
  }
  .padding()
  .background(AppColor.grayscale200)
}
