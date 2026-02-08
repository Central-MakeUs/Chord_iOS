import SwiftUI

public struct ToastBanner: View {
  let message: String
  
  public init(message: String) {
    self.message = message
  }
  
  public var body: some View {
    HStack(spacing: 8) {
      ZStack {
        Circle()
          .fill(AppColor.primaryBlue500)
          .frame(width: 20, height: 20)
        
        Image(systemName: "checkmark")
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.white)
      }
      
      Text(message)
        .font(.pretendardBody2)
        .foregroundColor(.white)
      
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(AppColor.grayscale700)
    .cornerRadius(12)
  }
}

public struct ToastBannerModifier: ViewModifier {
  @Binding var isPresented: Bool
  let message: String
  let duration: TimeInterval
  
  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottom) {
        if isPresented {
          ToastBanner(message: message)
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: 0.3)) {
                  isPresented = false
                }
              }
            }
        }
      }
      .animation(.easeInOut(duration: 0.3), value: isPresented)
  }
}

public extension View {
  func toastBanner(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 1.0) -> some View {
    modifier(ToastBannerModifier(isPresented: isPresented, message: message, duration: duration))
  }
}

public struct SpeechBubbleBanner: View {
  private let text: String
  private let tailTrailingPadding: CGFloat
  public init(text: String, tailTrailingPadding: CGFloat = 20) {
    self.text = text
    self.tailTrailingPadding = tailTrailingPadding
  }

  public var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      Image.speechBubbleTail
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 10, height: 10)
        .foregroundColor(AppColor.grayscale800)
        .padding(.trailing, tailTrailingPadding)
        .padding(.bottom, -2)

      Text(text)
        .font(.pretendardCaption2)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColor.grayscale800)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(text))
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.3).ignoresSafeArea()
    ToastBanner(message: "수정이 반영되었어요!")
      .padding(.horizontal, 20)
  }
}
