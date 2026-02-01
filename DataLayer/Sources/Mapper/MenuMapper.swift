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
      status: marginGradeCodeToStatus(marginGradeCode),
      costRate: String(format: "%.1f%%", costRate * 100),
      marginRate: String(format: "%.1f%%", marginRate * 100),
      costAmount: "0원",
      contribution: "0원",
      ingredients: [],
      totalIngredientCost: "0원"
    )
  }
  
  private func marginGradeCodeToStatus(_ code: String) -> MenuStatus {
    switch code {
    case "SAFE": return .safe
    case "WARNING": return .warning
    case "DANGER": return .danger
    default: return .safe
    }
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
      status: marginGradeCodeToStatus(marginGradeCode),
      costRate: String(format: "%.1f%%", costRate * 100),
      marginRate: String(format: "%.1f%%", marginRate * 100),
      costAmount: String(format: "%.0f원", totalCost),
      contribution: String(format: "%.0f원", contributionMargin),
      ingredients: [],
      totalIngredientCost: String(format: "%.0f원", totalCost)
    )
  }
  
  private func marginGradeCodeToStatus(_ code: String) -> MenuStatus {
    switch code {
    case "SAFE": return .safe
    case "WARNING": return .warning
    case "DANGER": return .danger
    default: return .safe
    }
  }
}
