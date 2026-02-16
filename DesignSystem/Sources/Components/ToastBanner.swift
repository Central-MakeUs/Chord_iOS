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
  let bottomPadding: CGFloat
  @State private var dismissTask: Task<Void, Never>?
  
  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottom) {
        if isPresented {
          ToastBanner(message: message)
            .padding(.horizontal, 20)
            .padding(.bottom, bottomPadding)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
              dismissTask?.cancel()
              dismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                  isPresented = false
                }
              }
            }
            .onDisappear {
              dismissTask?.cancel()
            }
        }
      }
      .onDisappear {
        dismissTask?.cancel()
      }
      .animation(.easeInOut(duration: 0.3), value: isPresented)
  }
}

public extension View {
  func toastBanner(
    isPresented: Binding<Bool>,
    message: String,
    duration: TimeInterval = 1.0,
    bottomPadding: CGFloat = 24
  ) -> some View {
    modifier(
      ToastBannerModifier(
        isPresented: isPresented,
        message: message,
        duration: duration,
        bottomPadding: bottomPadding
      )
    )
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
        .frame(width: 12, height: 12)
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
