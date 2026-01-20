import SwiftUI
import CoreModels
import DesignSystem

public struct MenuIngredientsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var ingredients: [IngredientItem]
  @State private var selectedTab: IngredientTab = .ingredient
  @State private var showAddSheet: Bool = false
  
  let menuName: String
  
  public init(menuName: String, ingredients: [IngredientItem]) {
    self.menuName = menuName
    self._ingredients = State(initialValue: ingredients)
  }
  
  enum IngredientTab: String, CaseIterable {
    case sourceSearch = "출처찾기"
    case ingredient = "식재료"
    case operatingIngredient = "운영 재료"
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      topBar
      
      HStack(spacing: 8) {
        ForEach(IngredientTab.allCases, id: \.self) { tab in
          Button(action: { selectedTab = tab }) {
            Text(tab.rawValue)
              .font(.pretendardBody2)
              .foregroundColor(selectedTab == tab ? AppColor.grayscale900 : AppColor.grayscale600)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .fill(selectedTab == tab ? AppColor.grayscale200 : Color.clear)
              )
          }
          .buttonStyle(.plain)
        }
        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 12)
      
      ScrollView {
        VStack(spacing: 0) {
          ForEach(ingredients) { ingredient in
            ingredientRow(ingredient: ingredient)
            
            if ingredient.id != ingredients.last?.id {
              Divider()
                .background(AppColor.grayscale300)
                .padding(.leading, 20)
            }
          }
        }
      }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .sheet(isPresented: $showAddSheet) {
      AddIngredientSheet { newIngredient in
        ingredients.append(newIngredient)
      }
      .presentationDetents([.height(600)])
    }
  }
  
  private var topBar: some View {
    HStack(spacing: 16) {
      HStack(spacing: 4) {
        Text("재료")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)
        Text("\(ingredients.count)")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.primaryBlue500)
      }
      
      Spacer()
      
      Button(action: {}) {
        Image.searchIcon
          .frame(width: 24, height: 24)
      }
      
      Button(action: {}) {
        Image.meatballIcon
          .frame(width: 24, height: 24)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  private func ingredientRow(ingredient: IngredientItem) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Text(ingredient.name)
        .font(.pretendardBody1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.leading, 20)
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(ingredient.price)
          .font(.pretendardBody1)
          .foregroundColor(AppColor.primaryBlue500)
        Text("사용량 \(ingredient.amount)")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale600)
      }
      .padding(.trailing, 20)
    }
    .padding(.vertical, 20)
    .contentShape(Rectangle())
  }
}

#Preview {
  NavigationStack {
    MenuIngredientsView(
      menuName: "바닐라 라떼",
      ingredients: [
        IngredientItem(name: "우유", amount: "30g", price: "800원"),
        IngredientItem(name: "설탕", amount: "30g", price: "800원"),
        IngredientItem(name: "시럽", amount: "30g", price: "800원"),
        IngredientItem(name: "초콜릿 가루", amount: "30g", price: "800원"),
        IngredientItem(name: "생크림", amount: "30g", price: "800원"),
        IngredientItem(name: "바닐라 엑스트랙", amount: "30g", price: "800원"),
        IngredientItem(name: "종이컵", amount: "30g", price: "800원"),
        IngredientItem(name: "컵 홀더", amount: "30g", price: "800원")
      ]
    )
  }
}
