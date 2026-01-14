import SwiftUI

public struct ProfitCard: View {
  public init() {}

  public var body: some View {
    HStack(spacing: 0) {
      ProfitCell(title: "마진율\n위험", value: "2", valueColor: AppColor.semanticWarningText, subtitle: nil)
      VerticalDivider()
      ProfitCell(title: "평균\n원가율", value: "28.5%", valueColor: AppColor.grayscale900, subtitle: nil)
      VerticalDivider()
      ProfitCell(title: "총 공연\n이익 전망", value: "+12%", valueColor: AppColor.grayscale900, subtitle: "(전주 대비)")
    }
    .padding(.vertical, 14)
    .background(AppColor.grayscale100)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.grayscale400, lineWidth: 1)
    )
  }
}

private struct ProfitCell: View {
  let title: String
  let value: String
  let valueColor: Color
  let subtitle: String?
  
  var body: some View {
    VStack(spacing: 6) {
      Text(title)
        .font(.pretendardCaption)
        .multilineTextAlignment(.center)
        .foregroundColor(AppColor.grayscale700)
      Text(value)
        .font(.pretendardTitle1)
        .foregroundColor(valueColor)
      if let subtitle {
        Text(subtitle)
          .font(.pretendardCaption)
          .foregroundColor(AppColor.grayscale700)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

private struct VerticalDivider: View {
  var body: some View {
    Divider()
      .frame(height: 54)
      .padding(.horizontal, 4)
      .background(AppColor.grayscale300)
  }
}
