import CoreModels
import Foundation

public extension IngredientResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    let displayPrice = currentUnitPrice * Double(baseQuantity)
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let formattedPrice = formatter.string(from: NSNumber(value: displayPrice)) ?? String(format: "%.0f", displayPrice)
    
    return InventoryIngredientItem(
      id: UUID(),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(baseQuantity)\(unitCode)",
      price: "\(formattedPrice)원",
      category: ingredientCategoryCode,
      supplier: nil
    )
  }
}

public extension IngredientDetailResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let formattedPrice = formatter.string(from: NSNumber(value: originalPrice)) ?? String(format: "%.0f", originalPrice)
    
    return InventoryIngredientItem(
      id: UUID(),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(Int(originalAmount))\(unitCode)",
      price: "\(formattedPrice)원",
      category: ingredientCategoryCode ?? "ETC",
      supplier: supplier,
      usedMenus: menus.map { UsedMenuInfo(menuName: $0.menuName, amount: $0.amount, unitCode: $0.unitCode) },
      isFavorite: isFavorite
    )
  }
}


public extension InventoryIngredientItem {
  static func from(apiResponse: IngredientResponse) -> InventoryIngredientItem {
    apiResponse.toInventoryIngredientItem()
  }
}
