import CoreModels
import Foundation

public extension MenuResponse {
  func toMenuItem() -> MenuItem {
    return MenuItem(
      id: UUID(),
      apiId: menuId,
      name: menuName,
      price: String(format: "%.0f원", sellingPrice),
      category: .all,
      status: MenuStatus.from(marginGradeCode: marginGradeCode),
      costRate: String(format: "%.1f%%", costRate),
      marginRate: String(format: "%.1f%%", marginRate),
      costAmount: "0원",
      contribution: "0원",
      ingredients: [],
      totalIngredientCost: "0원",
      recommendedPrice: nil,
      workTime: nil
    )
  }
  
}

public extension MenuDetailResponse {
  func toMenuItem() -> MenuItem {
    return MenuItem(
      id: UUID(),
      apiId: menuId,
      name: menuName,
      price: String(format: "%.0f원", sellingPrice),
      category: .all,
      status: MenuStatus.from(marginGradeCode: marginGradeCode),
      costRate: String(format: "%.1f%%", costRate),
      marginRate: String(format: "%.1f%%", marginRate),
      costAmount: String(format: "%.0f원", totalCost),
      contribution: String(format: "%.0f원", contributionMargin),
      ingredients: [],
      totalIngredientCost: String(format: "%.0f원", totalCost),
      recommendedPrice: String(format: "%.0f원", recommendedPrice),
      workTime: workTime
    )
  }
  
}
