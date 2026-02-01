import CoreModels
import Foundation

public extension IngredientResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    return InventoryIngredientItem(
      id: UUID(),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(baseQuantity)\(unitCode)",
      price: String(format: "%.0f원", currentUnitPrice),
      category: ingredientCategoryCode,
      supplier: nil
    )
  }
}

public extension IngredientDetailResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    return InventoryIngredientItem(
      id: UUID(),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(baseQuantity)\(unitCode)",
      price: String(format: "%.0f원", unitPrice),
      category: "ETC", // Detail response doesn't have category currently
      supplier: supplier
    )
  }
}


public extension InventoryIngredientItem {
  static func from(apiResponse: IngredientResponse) -> InventoryIngredientItem {
    apiResponse.toInventoryIngredientItem()
  }
}
