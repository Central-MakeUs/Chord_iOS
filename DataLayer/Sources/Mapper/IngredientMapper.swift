import CoreModels
import Foundation

private func stableIngredientUUID(_ ingredientId: Int) -> UUID {
  let value = UInt64(bitPattern: Int64(ingredientId))
  let bytes: uuid_t = (
    0x43, 0x43, 0x49, 0x4E,
    0x47, 0x52, 0x45, 0x44,
    UInt8((value >> 56) & 0xFF),
    UInt8((value >> 48) & 0xFF),
    UInt8((value >> 40) & 0xFF),
    UInt8((value >> 32) & 0xFF),
    UInt8((value >> 24) & 0xFF),
    UInt8((value >> 16) & 0xFF),
    UInt8((value >> 8) & 0xFF),
    UInt8(value & 0xFF)
  )
  return UUID(uuid: bytes)
}

private func formattedPriceText(_ value: Double) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.minimumFractionDigits = 0
  formatter.maximumFractionDigits = 2
  return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
}

public extension IngredientResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    let displayPrice = currentUnitPrice
    let formattedPrice = formattedPriceText(displayPrice)
    
    return InventoryIngredientItem(
      id: stableIngredientUUID(ingredientId),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(baseQuantity)\(IngredientUnit.from(unitCode).title)",
      price: "\(formattedPrice)원",
      category: ingredientCategoryCode,
      supplier: nil
    )
  }
}

public extension IngredientDetailResponse {
  func toInventoryIngredientItem() -> InventoryIngredientItem {
    let formattedPrice = formattedPriceText(unitPrice)
    
    return InventoryIngredientItem(
      id: stableIngredientUUID(ingredientId),
      apiId: ingredientId,
      name: ingredientName,
      amount: "\(baseQuantity)\(IngredientUnit.from(unitCode).title)",
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
