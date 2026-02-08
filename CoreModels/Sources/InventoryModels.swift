import Foundation

public struct UsedMenuInfo: Hashable {
  public let menuName: String
  public let amount: Double
  public let unitCode: String
  
  public init(menuName: String, amount: Double, unitCode: String) {
    self.menuName = menuName
    self.amount = amount
    self.unitCode = unitCode
  }
}

public struct InventoryIngredientItem: Identifiable, Hashable {
  public let id: UUID
  public let apiId: Int?
  public let name: String
  public let amount: String
  public let price: String
  public let category: String
  public let supplier: String?
  public let usedMenus: [UsedMenuInfo]
  public var isFavorite: Bool

  public init(
    id: UUID = UUID(),
    apiId: Int? = nil,
    name: String,
    amount: String,
    price: String,
    category: String = "ETC",
    supplier: String? = nil,
    usedMenus: [UsedMenuInfo] = [],
    isFavorite: Bool = false
  ) {
    self.id = id
    self.apiId = apiId
    self.name = name
    self.amount = amount
    self.price = price
    self.category = category
    self.supplier = supplier
    self.usedMenus = usedMenus
    self.isFavorite = isFavorite
  }
}
