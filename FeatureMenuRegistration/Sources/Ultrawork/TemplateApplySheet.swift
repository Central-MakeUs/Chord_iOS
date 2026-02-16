import SwiftUI
import DesignSystem

public struct TemplateApplySheet: View {
  let menuName: String
  let onApply: () -> Void
  let onCancel: () -> Void
  
  public init(menuName: String = "", onApply: @escaping () -> Void, onCancel: @escaping () -> Void) {
    self.menuName = menuName
    self.onApply = onApply
    self.onCancel = onCancel
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      SheetDragHandle()

      VStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 4) {
          Text("템플릿을 적용할까요?")
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)
            .multilineTextAlignment(.leading)
          
          VStack(spacing: 4) {
            Text("메뉴 구성과 재료 항목이 자동으로 채워져요")
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale700)
            
            Text("적용후에도 자유롭게 수정할 수 있어요")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)
          }
          .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 10)
        Spacer()
        actionButtons
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.white)
  }
  
  private var actionButtons: some View {
    HStack(spacing: 12) {
      Button(action: onCancel) {
        Text("아니요")
          .font(.pretendardCTA)
          .foregroundColor(AppColor.grayscale600)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(AppColor.grayscale400)
          .cornerRadius(12)
      }
      
      Button(action: onApply) {
        Text("적용하기")
              .font(.pretendardCTA)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(AppColor.primaryBlue500)
          .cornerRadius(12)
      }
    }
  }
}

#Preview {
  TemplateApplySheet(menuName: "아메리카노", onApply: {}, onCancel: {})
}
