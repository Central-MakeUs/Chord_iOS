import SwiftUI

public struct CoachCoachAlert: View {
  public enum AlertType {
    case oneButton
    case twoButton
  }

  let title: String
  let content: String?
  let alertType: AlertType
  let leftButtonTitle: String?
  let rightButtonTitle: String
  let leftButtonAction: (() -> Void)?
  let rightButtonAction: () -> Void
  
  public init(
    title: String,
    content: String? = nil,
    alertType: AlertType = .twoButton,
    leftButtonTitle: String? = "아니요",
    rightButtonTitle: String = "확인",
    leftButtonAction: (() -> Void)? = nil,
    rightButtonAction: @escaping () -> Void
  ) {
    self.title = title
    self.content = content
    self.alertType = alertType
    self.leftButtonTitle = leftButtonTitle
    self.rightButtonTitle = rightButtonTitle
    self.leftButtonAction = leftButtonAction
    self.rightButtonAction = rightButtonAction
  }
  
  public var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
      
      VStack(spacing: 32) {
        VStack(spacing: 8) {
          Text(title)
            .font(.pretendardBody3)
            .foregroundColor(AppColor.grayscale900)
            .multilineTextAlignment(.center)
          
          if let content = content {
            Text(content)
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale600)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.top, 20)
        .padding(.horizontal, 40)
        
        HStack(spacing: 12) {
          if alertType == .twoButton, let leftTitle = leftButtonTitle {
            Button {
              leftButtonAction?()
            } label: {
              Text(leftTitle)
                .font(.pretendardCTA)
                .foregroundColor(AppColor.grayscale600)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppColor.grayscale200)
                .cornerRadius(12)
            }
          }
          
          Button {
            rightButtonAction()
          } label: {
            Text(rightButtonTitle)
              .font(.pretendardCTA)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(AppColor.primaryBlue500)
              .cornerRadius(12)
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
      }
      .frame(width: 316)
      .background(Color.white)
      .cornerRadius(20)
      .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 4)
    }
  }
}

public extension View {
  func coachCoachAlert(
    isPresented: Binding<Bool>,
    title: String,
    content: String? = nil,
    alertType: CoachCoachAlert.AlertType = .twoButton,
    leftButtonTitle: String? = "아니요",
    rightButtonTitle: String = "확인",
    leftButtonAction: (() -> Void)? = nil,
    rightButtonAction: @escaping () -> Void
  ) -> some View {
    fullScreenCover(isPresented: isPresented) {
      CoachCoachAlert(
        title: title,
        content: content,
        alertType: alertType,
        leftButtonTitle: leftButtonTitle,
        rightButtonTitle: rightButtonTitle,
        leftButtonAction: {
          leftButtonAction?()
          isPresented.wrappedValue = false
        },
        rightButtonAction: {
          rightButtonAction()
          isPresented.wrappedValue = false
        }
      )
      .presentationBackground(.clear)
    }
  }
}


public struct ToastView: View {
  let message: String
  
  public init(message: String) {
    self.message = message
  }
  
  public var body: some View {
    Text(message)
      .font(.system(size: 14))
      .foregroundColor(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.black.opacity(0.8))
      .cornerRadius(24)
      .padding(.bottom, 40)
  }
}

public struct ToastModifier: ViewModifier {
  @Binding var isPresented: Bool
  let message: String
  let duration: TimeInterval
  
  public init(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 2.0) {
    self._isPresented = isPresented
    self.message = message
    self.duration = duration
  }
  
  public func body(content: Content) -> some View {
    ZStack(alignment: .bottom) {
      content
      
      if isPresented {
        ToastView(message: message)
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
              withAnimation {
                isPresented = false
              }
            }
          }
          .zIndex(100)
      }
    }
    .animation(.easeInOut, value: isPresented)
  }
}

public extension View {
  func toast(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 2.0) -> some View {
    self.modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
  }
}
