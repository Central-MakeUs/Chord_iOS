import SwiftUI
import Foundation

public struct PriceInputField: View {
  @Binding public var text: String
  public let placeholder: String
  public let height: CGFloat
  public let backgroundColor: Color

  @FocusState private var isFocused: Bool

  public init(
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

  public var body: some View {
    HStack(spacing: 8) {
      TextField(
        "",
        text: $text,
        prompt: Text(placeholder)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale400)
      )
      .font(.pretendardBody2)
      .foregroundColor(textColor)
      .keyboardType(.numberPad)
      .focused($isFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .onAppear {
        let digits = digitsOnly(from: text)
        let normalized = formattedDigits(digits)
        if text != normalized {
          text = normalized
        }
      }
      .onChange(of: isFocused) { focused in
        let digits = digitsOnly(from: text)
        let normalized = focused ? digits : formattedDigits(digits)
        if text != normalized {
          text = normalized
        }
      }
      .onChange(of: text) { newValue in
        let digits = digitsOnly(from: newValue)
        let normalized = isFocused ? digits : formattedDigits(digits)
        if normalized != newValue {
          text = normalized
        }
      }

      Text("원")
        .font(.pretendardCTA)
        .foregroundColor(AppColor.grayscale500)

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

  private func digitsOnly(from value: String) -> String {
    value.filter { $0.isNumber }
  }

  private func formattedDigits(_ digits: String) -> String {
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
  }
}

#Preview {
  VStack(spacing: 12) {
    PriceInputField(text: .constant("5,600"), placeholder: "가격 입력", height: 47)
    PriceInputField(text: .constant(""), placeholder: "가격 입력", height: 47)
  }
  .padding()
  .background(AppColor.grayscale100)
}
