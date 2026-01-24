import SwiftUI
import UIKit
import DesignSystem

public struct TemplateApplySheet: View {
  let onApply: () -> Void
  let onCancel: () -> Void
  
  public init(onApply: @escaping () -> Void, onCancel: @escaping () -> Void) {
    self.onApply = onApply
    self.onCancel = onCancel
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      Text("템플릿을 적용할까요?")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.top, 40)
        .padding(.bottom, 12)
      
      Text("코치코치에서 제공하는 기본 재료 정보를\n자동으로 입력해드려요.\n편리하게 메뉴를 등록해보세요.")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale600)
        .multilineTextAlignment(.center)
        .padding(.bottom, 40)
      
      HStack(spacing: 8) {
        BottomButton(
          title: "아니요",
          style: .secondary
        ) {
          onCancel()
        }
        
        BottomButton(
          title: "적용하기",
          style: .primary
        ) {
          onApply()
        }
      }
      .padding(.horizontal, 34)
      .padding(.bottom, 20)
    }
    .background(Color.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

#Preview {
  TemplateApplySheet(onApply: {}, onCancel: {})
}
