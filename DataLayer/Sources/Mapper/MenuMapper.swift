import CoreModels
import Foundation

public extension MenuResponse {
  func toMenuItem() -> MenuItem {
    return MenuItem(
      id: UUID(),
      apiId: menuId,
      name: menuName,
      price: formattedSellingPriceText(sellingPrice),
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
      price: formattedSellingPriceText(sellingPrice),
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

private func formattedSellingPriceText(_ value: Double) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.minimumFractionDigits = 0
  formatter.maximumFractionDigits = 6
  let formatted = formatter.string(from: NSNumber(value: value)) ?? String(value)
  return "\(formatted)원"
}
