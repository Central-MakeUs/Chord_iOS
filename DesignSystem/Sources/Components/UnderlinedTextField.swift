import SwiftUI

public struct UnderlinedTextField: View {
    @Binding public var text: String
    public let title: String?
    public let placeholder: String
    public let errorMessage: String?
    public let titleColor: Color
    public let textColor: Color
    public let placeholderColor: Color
    public let underlineColor: Color
    public let accentColor: Color
    public let errorColor: Color
    public let showFocusHighlight: Bool
    public let keyboardType: UIKeyboardType
    public let isSecure: Bool
    public let trailingIcon: Image?
    public let onTrailingTap: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        title: String? = nil,
        placeholder: String = "",
        errorMessage: String? = nil,
        titleColor: Color = AppColor.grayscale900,
        textColor: Color = AppColor.grayscale900,
        placeholderColor: Color = AppColor.grayscale500,
        underlineColor: Color = AppColor.grayscale300,
    accentColor: Color = AppColor.grayscale900,
        errorColor: Color = AppColor.error,
        showFocusHighlight: Bool = true,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        trailingIcon: Image? = nil,
        onTrailingTap: (() -> Void)? = nil
    ) {
        _text = text
        self.title = title
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.titleColor = titleColor
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.underlineColor = underlineColor
        self.accentColor = accentColor
        self.errorColor = errorColor
        self.showFocusHighlight = showFocusHighlight
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.trailingIcon = trailingIcon
        self.onTrailingTap = onTrailingTap
    }
    
    private var hasError: Bool {
        errorMessage != nil
    }
    
    private var currentTextColor: Color {
        hasError ? errorColor : textColor
    }
    
    private var currentUnderlineColor: Color {
        if hasError {
            return errorColor
        }
        if showFocusHighlight && isFocused {
            return accentColor
        }
        return underlineColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title, !title.isEmpty {
                Text(title)
                    .frame(minHeight: 20)
                    .font(.pretendardCaption1)
                    .foregroundColor(titleColor)
            }
            
            HStack(spacing: 8) {
                if isSecure {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.pretendardSubtitle2)
                            .foregroundColor(placeholderColor)
                    )
          .frame(minHeight: 30)
          .font(.pretendardSubtitle2)
          .foregroundColor(currentTextColor)
          .tint(accentColor)
          .focused($isFocused)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                            .font(.pretendardSubtitle2)
                            .foregroundColor(placeholderColor)
                    )
          .frame(minHeight: 30)
          .font(.pretendardSubtitle2)
          .foregroundColor(currentTextColor)
          .tint(accentColor)
          .keyboardType(keyboardType)
          .focused($isFocused)
          .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                }
                
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
                .fill(currentUnderlineColor)
                .frame(height: 1)
                .padding(.top, 2)
            
            if let errorMessage {
                Text(errorMessage)
                    .font(.pretendardCaption2)
                    .foregroundColor(errorColor)
            }
        }
        .onChange(of: text) { _, newValue in
            let sanitized = sanitizedText(newValue)
            if sanitized != newValue {
                text = sanitized
            }
        }
    }

    private func sanitizedText(_ value: String) -> String {
        switch keyboardType {
        case .numberPad, .asciiCapableNumberPad:
            return value.filter { $0.isNumber || $0 == "," }
        case .decimalPad:
            return sanitizedDecimalText(value)
        default:
            return value
        }
    }

    private func sanitizedDecimalText(_ value: String) -> String {
        let filtered = value.filter { $0.isNumber || $0 == "." || $0 == "," }
        var hasDot = false
        var result = ""

        for character in filtered {
            if character == "." {
                guard !hasDot else { continue }
                hasDot = true
            }
            result.append(character)
        }

        return result
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
