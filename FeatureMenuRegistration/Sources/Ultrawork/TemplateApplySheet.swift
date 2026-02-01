import SwiftUI
import UIKit
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
      dragHandle
      
      ScrollView {
        VStack(spacing: 24) {
          headerSection
          templatePreviewSection
          benefitsSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
      }
      
      actionButtons
    }
    .background(Color.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }
  
  private var dragHandle: some View {
    Rectangle()
      .fill(AppColor.grayscale300)
      .frame(width: 36, height: 4)
      .cornerRadius(2)
      .padding(.top, 12)
      .padding(.bottom, 8)
  }
  
  private var headerSection: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("템플릿 적용")
            .font(.pretendardTitle2)
            .foregroundColor(AppColor.grayscale900)
          
          Text("'\(menuName)' 기본 재료를 자동으로 추가합니다")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
        }
        
        Spacer()
        
        Image.starIcon
          .renderingMode(.template)
          .foregroundColor(Color.orange)
          .frame(width: 32, height: 32)
          .padding(12)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(12)
      }
    }
  }
  
  private var templatePreviewSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("포함될 재료")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
      
      VStack(spacing: 8) {
        templateIngredientRow("원두", "20g", "1,200원")
        templateIngredientRow("물", "240ml", "무료")
        templateIngredientRow("일회용컵", "1개", "150원")
        templateIngredientRow("설탕시럽", "10ml", "80원")
      }
      .padding(16)
      .background(AppColor.primaryBlue100)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(AppColor.primaryBlue200, lineWidth: 1)
      )
      
      HStack {
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          Text("예상 재료비")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text("1,430원")
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.primaryBlue600)
        }
      }
    }
  }
  
  private var benefitsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("템플릿 사용의 장점")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
      
      VStack(spacing: 8) {
        benefitRow("⚡️", "빠른 입력", "기본 재료 정보를 한 번에 추가")
        benefitRow("💰", "정확한 원가", "시장 평균 가격 기반의 정확한 계산")
        benefitRow("📊", "데이터 분석", "업계 표준과 비교 분석 가능")
      }
    }
  }
  
  private var actionButtons: some View {
    VStack(spacing: 0) {
      Divider()
        .background(AppColor.grayscale200)
      
      HStack(spacing: 12) {
        BottomButton(
          title: "직접 입력",
          style: .secondary
        ) {
          onCancel()
        }
        
        BottomButton(
          title: "템플릿 적용",
          style: .primary
        ) {
          onApply()
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 20)
      .background(Color.white)
    }
  }
  
  private func templateIngredientRow(_ name: String, _ amount: String, _ price: String) -> some View {
    HStack {
      Text(name)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      
      Spacer()
      
      Text(amount)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale600)
      
      Text(price)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.primaryBlue600)
        .frame(minWidth: 60, alignment: .trailing)
    }
  }
  
  private func benefitRow(_ icon: String, _ title: String, _ description: String) -> some View {
    HStack(spacing: 12) {
      Text(icon)
        .font(.system(size: 20))
      
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        Text(description)
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)
      }
      
      Spacer()
    }
    .padding(.vertical, 4)
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
  TemplateApplySheet(menuName: "아메리카노", onApply: {}, onCancel: {})
}
