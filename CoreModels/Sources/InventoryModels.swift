import Foundation

public struct InventoryIngredientItem: Identifiable, Hashable {
  public let id: UUID
  public let apiId: Int?
  public let name: String
  public let amount: String
  public let price: String
  public let category: String
  public let supplier: String?

  public init(
    id: UUID = UUID(),
    apiId: Int? = nil,
    name: String,
    amount: String,
    price: String,
    category: String = "ETC",
    supplier: String? = nil
  ) {
    self.id = id
    self.apiId = apiId
    self.name = name
    self.amount = amount
    self.price = price
    self.category = category
    self.supplier = supplier
  }
}
