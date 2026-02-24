import SwiftUI
import CoreModels
import DesignSystem

public struct IngredientDetailSheet: View {
  @Environment(\.dismiss) private var dismiss
  let ingredient: MenuRegistrationFeature.RegistrationIngredient

  public init(ingredient: MenuRegistrationFeature.RegistrationIngredient) {
    self.ingredient = ingredient
  }

  public var body: some View {
    VStack(spacing: 0) {
      Color.clear.frame(height: 40)

      NavigationTopBar(
        onBackTap: { dismiss() },
        title: "재료 상세",
        trailing: .text("편집", action: { })
      )

      ScrollView {
        VStack(spacing: 20) {
          ingredientHeroSection
          
          VStack(spacing: 16) {
            detailInfoSection
            usageSection
            priceAnalysisSection
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
      }
      
      actionButtons
    }
    .background(Color.white.ignoresSafeArea())
  }

  private var ingredientHeroSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          Text(ingredient.name)
            .font(.pretendardTitle2)
            .foregroundColor(AppColor.grayscale900)
          
          Text(IngredientUnit.from(ingredient.unitCode).title)
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColor.grayscale100)
            .cornerRadius(6)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("재료비")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text(ingredient.formattedPrice)
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.primaryBlue600)
        }
      }
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("사용량")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text(ingredient.formattedAmount)
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("단위당 비용")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text(ingredient.formattedPrice)
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
        }
      }
    }
    .padding(24)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
  }

  private var detailInfoSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("상세 정보")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)

      VStack(spacing: 16) {
        detailRow(label: "재료명", value: ingredient.name)
        detailRow(label: "사용량", value: ingredient.formattedAmount)
        detailRow(label: "단위", value: IngredientUnit.from(ingredient.unitCode).title)
        detailRow(label: "가격", value: ingredient.formattedPrice)
      }
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private var usageSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("사용 현황")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 16) {
        VStack(spacing: 8) {
          Text("이번 달")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text("3회")
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
          Text("사용")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColor.primaryBlue100)
        .cornerRadius(8)
        
        VStack(spacing: 8) {
          Text("평균 사용량")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale600)
          Text(ingredient.formattedAmount)
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
          Text("per 메뉴")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(8)
      }
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private var priceAnalysisSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("가격 분석")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)

      VStack(spacing: 12) {
        HStack {
          Text("시장 평균 대비")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
          Spacer()
          HStack(spacing: 4) {
            Text("5% 절약")
              .font(.pretendardSubtitle3)
              .foregroundColor(AppColor.semanticSafe)
            Image.caretDownIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.semanticSafe)
              .frame(width: 16, height: 16)
          }
        }
        
        HStack {
          Text("지난 달 대비")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
          Spacer()
          HStack(spacing: 4) {
            Text("2% 상승")
              .font(.pretendardSubtitle3)
              .foregroundColor(AppColor.semanticWarning)
            Image.caretUpIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.semanticWarning)
              .frame(width: 16, height: 16)
          }
        }
      }
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private var actionButtons: some View {
    VStack(spacing: 0) {
      
      HStack(spacing: 12) {
        BottomButton(
          title: "삭제",
          style: .secondary
        ) {
        }
        BottomButton(
          title: "수정",
          style: .primary
        ) {
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 20)
      .background(Color.white)
    }
  }

  private func detailRow(label: String, value: String, icon: Image? = nil) -> some View {
    HStack(spacing: 12) {
      if let icon = icon {
        icon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale400)
          .frame(width: 20, height: 20)
      }
      
      Text(label)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale600)
      
      Spacer()
      
      Text(value)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
    }
    .padding(.vertical, 8)
  }
}
