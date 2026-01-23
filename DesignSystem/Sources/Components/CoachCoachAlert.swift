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
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
            .multilineTextAlignment(.center)
          
          if let content = content {
            Text(content)
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale600)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.top, 40)
        .padding(.horizontal, 24)
        
        HStack(spacing: 12) {
          if alertType == .twoButton, let leftTitle = leftButtonTitle {
            Button {
              leftButtonAction?()
            } label: {
              Text(leftTitle)
                .font(.pretendardSubtitle2)
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
              .font(.pretendardSubtitle2)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(AppColor.primaryBlue500)
              .cornerRadius(12)
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
      }
      .frame(width: 300)
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

#Preview {
  ZStack {
    Color.gray.ignoresSafeArea()
    
    VStack(spacing: 20) {
      CoachCoachAlert(
        title: "메뉴를 삭제하시겠어요?",
        alertType: .twoButton,
        rightButtonTitle: "삭제하기",
        leftButtonAction: {},
        rightButtonAction: {}
      )
      
      CoachCoachAlert(
        title: "메뉴가 삭제 됐어요",
        alertType: .oneButton,
        rightButtonTitle: "확인",
        rightButtonAction: {}
      )
    }
  }
}
