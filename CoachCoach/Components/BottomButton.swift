import SwiftUI

struct BottomButton: View {
  enum Style {
    case primary
    case secondary
    case tertiary
    
    var backgroundColor: Color {
      switch self {
      case .primary:
        return AppColor.primaryBlue500
      case .secondary:
        return AppColor.grayscale400
      case .tertiary:
        return .clear
      }
    }
    
    var textColor: Color {
      switch self {
      case .primary:
        return AppColor.grayscale100
      case .secondary:
        return AppColor.grayscale600
      case .tertiary:
        return AppColor.grayscale500
      }
    }
    
    var borderColor: Color? {
      switch self {
      case .primary, .secondary:
        return nil
      case .tertiary:
        return AppColor.grayscale500
      }
    }
  }
  
  let title: String
  let height: CGFloat
  let style: Style
  let action: () -> Void
  
  init(
    title: String,
    height: CGFloat = 52,
    style: Style = .primary,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.height = height
    self.style = style
    self.action = action
  }
  
  var body: some View {
    Button {
      action()
    } label: {
      Text(title)
        .font(.pretendardCTA)
        .foregroundColor(style.textColor)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(style.backgroundColor)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(style.borderColor ?? .clear, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack(spacing: 12) {
    BottomButton(title: "Label", style: .primary) {}
    BottomButton(title: "Label", style: .secondary) {}
    BottomButton(title: "Label", style: .tertiary) {}
  }
  .padding()
  .background(AppColor.grayscale100)
}
