import CoreModels
import SwiftUI

public struct MenuStatusBadge: View {
  public let status: MenuStatus

  public init(status: MenuStatus) {
    self.status = status
  }

  public var body: some View {
    Text(status.text)
      .font(.pretendardCaption3)
      .foregroundColor(status.badgeTextColor)
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(status.badgeBackgroundColor)
      )
  }
}

private extension MenuStatus {
  var color: Color {
    switch self {
    case .safe: return AppColor.semanticSafeText
    case .normal: return AppColor.primaryBlue500
    case .warning: return AppColor.semanticCautionText
    case .danger: return AppColor.semanticWarningText
    }
  }

  var badgeBackgroundColor: Color {
    color.opacity(0.15)
  }

  var badgeTextColor: Color {
    color
  }
}
