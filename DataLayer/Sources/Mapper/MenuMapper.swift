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
  
  private func marginGradeCodeToStatus(_ code: String) -> MenuStatus {
    switch code {
    case "SAFE": return .safe
    case "NORMAL": return .normal
    case "WARNING": return .warning
    case "DANGER": return .danger
    default: return .normal
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
  
  private func marginGradeCodeToStatus(_ code: String) -> MenuStatus {
    switch code {
    case "SAFE": return .safe
    case "NORMAL": return .normal
    case "WARNING": return .warning
    case "DANGER": return .danger
    default: return .normal
    }
  }
}
