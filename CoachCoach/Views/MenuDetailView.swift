import SwiftUI

struct MenuDetailView: View {
  let item: MenuItem
  @Environment(\.dismiss) private var dismiss

  private let recommendedPrice = "6,000원"
  private let recommendedMessage = "원가율이 높아요 가격을 조정해보세요"
  
  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          titleSection
          profitSummaryCard
          Divider()
            .background(AppColor.grayscale200)
          marginGradeCard
          recommendedPriceSection
          ingredientsSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.visible, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: { dismiss() }) {
          Image.arrowLeftIcon
            .renderingMode(.template)
            .foregroundStyle(AppColor.grayscale900)
            .frame(width: 20, height: 20)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {}) {
          Text("관리")
            .font(.pretendardBody1)
            .foregroundStyle(AppColor.grayscale700)
        }
      }
    }
  }
  
  private var titleSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(item.name)
        .font(.pretendardSubTitle)
        .foregroundStyle(AppColor.grayscale900)
      Text(item.price)
        .font(.pretendardTitle1)
        .foregroundStyle(AppColor.grayscale900)
    }
  }
  
  private var profitSummaryCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      summaryRow(label: "마진율", value: item.marginRate)
      summaryRow(label: "총 원가 (원가율)", value: "\(item.costAmount) (\(item.costRate))")
      HStack(spacing: 4) {
        HStack(spacing: 0) {
          Text("공헌이익")
            .font(.pretendardCaption)
          Image.infoFilledIcon
            .renderingMode(.template)
        }
        .foregroundStyle(AppColor.grayscale700)
        Spacer()
        Text(item.contribution)
          .font(.pretendardBody2)
          .foregroundStyle(AppColor.grayscale900)
      }
    }
    .padding(16)
    .background(AppColor.grayscale200)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
  
  private func summaryRow(label: String, value: String) -> some View {
    HStack {
      Text(label)
        .font(.pretendardBody2)
        .foregroundStyle(AppColor.grayscale700)
      Spacer()
      Text(value)
        .font(.pretendardBody2)
        .foregroundStyle(AppColor.grayscale900)
    }
  }
  
  private var marginGradeCard: some View {
    HStack(spacing: 6) {
      Text("마진등급")
        .font(.pretendardCTA)
        .foregroundStyle(AppColor.grayscale700)
      MenuBadge(status: item.status)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(AppColor.grayscale200)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
  
  private var recommendedPriceSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("권장가격")
        .font(.pretendardSubTitle)
        .foregroundStyle(AppColor.grayscale900)
      VStack(spacing: 6) {
        Text(recommendedPrice)
          .font(.pretendardTitle1)
          .foregroundStyle(AppColor.primaryBlue500)
        Text(recommendedMessage)
          .font(.pretendardCaption)
          .foregroundStyle(AppColor.grayscale700)
      }
      .frame(maxWidth: .infinity)
    }
  }
  
  private var ingredientsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 4) {
        Text("재료")
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.grayscale900)
        Text("\(item.ingredients.count)")
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.primaryBlue500)
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundStyle(AppColor.grayscale600)
        Spacer()
      }
      
      VStack(spacing: 10) {
        ForEach(item.ingredients) { ingredient in
          HStack {
            Text("\(ingredient.name) (\(ingredient.amount))")
            Spacer()
            Text(ingredient.price)
          }
          .font(.pretendardBody2)
          .foregroundStyle(AppColor.grayscale700)
        }
      }
      
      Divider()
        .background(AppColor.grayscale300)
      
      HStack(spacing: 4) {
        Spacer()
        Text("총")
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.grayscale700)
        Text(item.totalIngredientCost)
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.grayscale900)
      }
      
      BottomButton(title: "재료 추가", style: .tertiary) {}
    }
  }
}

#Preview {
  let ingredients = [
    IngredientItem(name: "원두", amount: "30g", price: "450원"),
    IngredientItem(name: "돌체 시나몬 시럽", amount: "10ml", price: "250원"),
    IngredientItem(name: "우유", amount: "230ml", price: "750원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
    IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
  let item = MenuItem(
    name: "돌체라떼",
    price: "5,600원",
    category: .beverage,
    status: .danger,
    costRate: "62.9%",
    marginRate: "23.2%",
    costAmount: "1,200원",
    contribution: "3,670원",
    ingredients: ingredients,
    totalIngredientCost: "1,450원"
  )
  MenuDetailView(item: item)
    .environment(\.colorScheme, .light)
}
