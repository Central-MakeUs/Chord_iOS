import SwiftUI

struct UnderlinedTextField: View {
  @Binding var text: String
  let title: String?
  let placeholder: String
  let titleColor: Color
  let textColor: Color
  let placeholderColor: Color
  let underlineColor: Color
  let accentColor: Color
  let keyboardType: UIKeyboardType
  let trailingIcon: Image?
  let onTrailingTap: (() -> Void)?

  @FocusState private var isFocused: Bool

  init(
    text: Binding<String>,
    title: String? = nil,
    placeholder: String,
    titleColor: Color = AppColor.grayscale700,
    textColor: Color = AppColor.grayscale900,
    placeholderColor: Color = AppColor.grayscale400,
    underlineColor: Color = AppColor.grayscale300,
    accentColor: Color = AppColor.primaryBlue500,
    keyboardType: UIKeyboardType = .default,
    trailingIcon: Image? = nil,
    onTrailingTap: (() -> Void)? = nil
  ) {
    _text = text
    self.title = title
    self.placeholder = placeholder
    self.titleColor = titleColor
    self.textColor = textColor
    self.placeholderColor = placeholderColor
    self.underlineColor = underlineColor
    self.accentColor = accentColor
    self.keyboardType = keyboardType
    self.trailingIcon = trailingIcon
    self.onTrailingTap = onTrailingTap
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let title, !title.isEmpty {
        Text(title)
          .font(.pretendardCaption1)
          .foregroundColor(titleColor)
      }

      HStack(spacing: 8) {
        TextField(
          "",
          text: $text,
          prompt: Text(placeholder)
            .font(.pretendardBody2)
            .foregroundColor(placeholderColor)
        )
        .font(.pretendardBody2)
        .foregroundColor(textColor)
        .keyboardType(keyboardType)
        .focused($isFocused)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if let trailingIcon {
          if let onTrailingTap {
            Button(action: onTrailingTap) {
              trailingIcon
                .renderingMode(.template)
                .foregroundColor(AppColor.grayscale500)
                .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
          } else {
            trailingIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale500)
              .frame(width: 20, height: 20)
          }
        }
      }

      Rectangle()
        .fill(isFocused ? accentColor : underlineColor)
        .frame(height: 1)
    }
  }
}

#Preview {
  VStack(spacing: 24) {
    UnderlinedTextField(
      text: .constant(""),
      title: "매장명",
      placeholder: "예) 코치카페 강남점"
    )

    UnderlinedTextField(
      text: .constant("서울특별시 청파동 11-2"),
      title: "매장 주소",
      placeholder: "도로명 주소 입력",
      titleColor: AppColor.primaryBlue500,
      trailingIcon: Image.searchIcon
    )
  }
  .padding()
  .background(AppColor.grayscale100)
}
