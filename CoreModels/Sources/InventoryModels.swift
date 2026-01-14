import Foundation

public struct InventoryIngredientItem: Identifiable, Hashable {
  public let id: UUID
  public let name: String
  public let amount: String
  public let price: String

  public init(
    id: UUID = UUID(),
    name: String,
    amount: String,
    price: String
  ) {
    self.id = id
    self.name = name
    self.amount = amount
    self.price = price
  }
}
