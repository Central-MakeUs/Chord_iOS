import SwiftUI
import DesignSystem

public struct IngredientDetailSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var applyRecommendedPrice: Bool = false
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      topBar
      
      ScrollView {
        VStack(spacing: 12) {
          menuInfoCard
          marginInfoCard
          ingredientsCard
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
      }
    }
    .background(AppColor.grayscale200.ignoresSafeArea())
  }
  
  private var topBar: some View {
    HStack {
      Button(action: { dismiss() }) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
      }
      Spacer()
      Button(action: {}) {
        Text("관리")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  private var menuInfoCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("바닐라 라떼")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
      
      HStack(alignment: .top) {
        Text("6,500원")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text("제조시간")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale600)
          Text("1분 30초")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
      }
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private var marginInfoCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 8) {
        Text("마진률")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        
        Text("위험")
          .font(.pretendardCaption2)
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(AppColor.semanticWarningText)
          .cornerRadius(4)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text("원가율이 너무 높은 편이에요!")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Text("가격 또는 원가 구조를 점검해 주세요")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale600)
      }
      
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          Text("마진율")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale600)
          Text("50.6%")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
        .frame(maxWidth: .infinity)
        
        VStack(spacing: 4) {
          Text("원가율")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale600)
          Text("62.9%")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
        .frame(maxWidth: .infinity)
        
        VStack(spacing: 4) {
          Text("공헌이익")
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale600)
          Text("3,670원")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.vertical, 12)
      
      Button(action: { applyRecommendedPrice.toggle() }) {
        HStack(spacing: 8) {
          Image(systemName: applyRecommendedPrice ? "checkmark.square.fill" : "square")
            .font(.system(size: 20))
            .foregroundColor(applyRecommendedPrice ? AppColor.primaryBlue500 : AppColor.grayscale400)
          
          Text("권장가격 ")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
          + Text("6,000원")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.primaryBlue500)
        }
      }
      .buttonStyle(.plain)
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private var ingredientsCard: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("재료 ")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        + Text("4")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.primaryBlue500)
        
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale500)
          .frame(width: 16, height: 16)
        
        Spacer()
      }
      
      VStack(spacing: 12) {
        ingredientRow(name: "원두", amount: "30g", price: "450원")
        ingredientRow(name: "바닐라 시럽", amount: "10ml", price: "250원")
        ingredientRow(name: "우유", amount: "230ml", price: "750원")
        ingredientRow(name: "종이컵", amount: "1개", price: "100원")
      }
      
      Text("총 1,450원")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(12)
  }
  
  private func ingredientRow(name: String, amount: String, price: String) -> some View {
    HStack {
      Text("\(name) (\(amount))")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      Text(price)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
    }
  }
}

#Preview {
  IngredientDetailSheet()
}
