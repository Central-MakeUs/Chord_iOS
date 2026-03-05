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
  var badgeTextColor: Color {
    switch self {
    case .safe: return AppColor.semanticSafeText
    case .normal: return AppColor.primaryBlue700
    case .warning: return AppColor.semanticCautionText
    case .danger: return AppColor.semanticWarningText
    }
  }

  var badgeBackgroundColor: Color {
    switch self {
    case .safe: return AppColor.semanticSafe
    case .normal: return AppColor.primaryBlue100
    case .warning: return AppColor.semanticCaution
    case .danger: return AppColor.semanticWarning
    }
  }
}
