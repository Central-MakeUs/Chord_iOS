import SwiftUI
import ComposableArchitecture
import FeatureMenu
import CoreModels

@main
struct FeatureMenuDemoApp: App {
  
  private let sampleIngredients1 = [
    IngredientItem(name: "원두", amount: "30g", price: "450원"),
    IngredientItem(name: "물", amount: "250ml", price: "150원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원")
  ]
  
  private let sampleIngredients2 = [
    IngredientItem(name: "원두", amount: "30g", price: "450원"),
    IngredientItem(name: "우유", amount: "230ml", price: "750원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
    IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
  
  private let sampleIngredients3 = [
    IngredientItem(name: "원두", amount: "30g", price: "450원"),
    IngredientItem(name: "바닐라 시럽", amount: "10ml", price: "250원"),
    IngredientItem(name: "우유", amount: "230ml", price: "750원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
    IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
  
  var body: some Scene {
    WindowGroup {
      MenuView(
        store: Store(
          initialState: MenuFeature.State(
            menuItems: [
              MenuItem(
                name: "아메리카노",
                price: "4,500원",
                category: .beverage,
                status: .safe,
                costRate: "22.2%",
                marginRate: "30.5%",
                costAmount: "1,000원",
                contribution: "3,500원",
                ingredients: sampleIngredients1,
                totalIngredientCost: "1,000원"
              ),
              MenuItem(
                name: "카페라떼",
                price: "5,000원",
                category: .beverage,
                status: .warning,
                costRate: "30.0%",
                marginRate: "25.0%",
                costAmount: "1,500원",
                contribution: "3,500원",
                ingredients: sampleIngredients2,
                totalIngredientCost: "1,500원"
              ),
              MenuItem(
                name: "카푸치노",
                price: "5,500원",
                category: .beverage,
                status: .danger,
                costRate: "35.5%",
                marginRate: "20.0%",
                costAmount: "1,950원",
                contribution: "3,550원",
                ingredients: sampleIngredients2,
                totalIngredientCost: "1,950원"
              ),
              MenuItem(
                name: "초콜릿 케이크",
                price: "6,000원",
                category: .dessert,
                status: .safe,
                costRate: "25.0%",
                marginRate: "28.0%",
                costAmount: "1,500원",
                contribution: "4,500원",
                ingredients: sampleIngredients2,
                totalIngredientCost: "1,500원"
              ),
              MenuItem(
                name: "치즈케이크",
                price: "6,500원",
                category: .dessert,
                status: .warning,
                costRate: "32.0%",
                marginRate: "22.0%",
                costAmount: "2,080원",
                contribution: "4,420원",
                ingredients: sampleIngredients2,
                totalIngredientCost: "2,080원"
              ),
              MenuItem(
                name: "티라미수",
                price: "7,000원",
                category: .dessert,
                status: .safe,
                costRate: "28.5%",
                marginRate: "26.0%",
                costAmount: "1,995원",
                contribution: "5,005원",
                ingredients: sampleIngredients3,
                totalIngredientCost: "1,995원"
              ),
              MenuItem(
                name: "에스프레소",
                price: "3,500원",
                category: .beverage,
                status: .safe,
                costRate: "20.0%",
                marginRate: "35.0%",
                costAmount: "700원",
                contribution: "2,800원",
                ingredients: sampleIngredients1,
                totalIngredientCost: "700원"
              ),
              MenuItem(
                name: "바닐라라떼",
                price: "5,500원",
                category: .beverage,
                status: .warning,
                costRate: "31.8%",
                marginRate: "24.0%",
                costAmount: "1,749원",
                contribution: "3,751원",
                ingredients: sampleIngredients3,
                totalIngredientCost: "1,749원"
              )
            ]
          )
        ) {
          MenuFeature()
        }
      )
      .environment(\.colorScheme, .light)
    }
  }
}
