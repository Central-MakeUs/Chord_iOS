import CoreModels
import Foundation

public enum MockMenuData {
  public static let items: [MenuItem] = [
    MenuItem(
      apiId: 1,
      name: "돌체 라떼",
      price: "5,500원",
      category: .beverage,
      status: .danger,
      costRate: "33.4%",
      marginRate: "23.2%",
      costAmount: "1,840원",
      contribution: "3,660원",
      ingredients: sampleIngredients,
      totalIngredientCost: "1,450원"
    ),
    MenuItem(
      apiId: 2,
      name: "바닐라 라떼",
      price: "6,500원",
      category: .beverage,
      status: .warning,
      costRate: "24.4%",
      marginRate: "23.2%",
      costAmount: "1,590원",
      contribution: "4,910원",
      ingredients: sampleIngredients,
      totalIngredientCost: "1,300원"
    ),
    MenuItem(
      apiId: 3,
      name: "레몬티",
      price: "5,500원",
      category: .beverage,
      status: .safe,
      costRate: "33.4%",
      marginRate: "23.2%",
      costAmount: "1,840원",
      contribution: "3,660원",
      ingredients: sampleIngredients,
      totalIngredientCost: "1,180원"
    ),
    MenuItem(
      apiId: 4,
      name: "초콜릿 케익",
      price: "6,000원",
      category: .dessert,
      status: .safe,
      costRate: "30.0%",
      marginRate: "25.0%",
      costAmount: "1,800원",
      contribution: "4,200원",
      ingredients: sampleIngredients,
      totalIngredientCost: "900원"
    ),
    MenuItem(
      apiId: 5,
      name: "바나나 브레드",
      price: "4,200원",
      category: .dessert,
      status: .safe,
      costRate: "28.5%",
      marginRate: "20.0%",
      costAmount: "1,200원",
      contribution: "3,000원",
      ingredients: sampleIngredients,
      totalIngredientCost: "1,600원"
    )
  ]
  
  private static let sampleIngredients: [IngredientItem] = [
    IngredientItem(name: "에스프레소 샷", amount: "30ml", price: "450원"),
    IngredientItem(name: "우유", amount: "230ml", price: "750원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
    IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
}
