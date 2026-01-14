import Foundation

public enum MenuCategory: String, CaseIterable, Identifiable, Hashable {
  case all = "전체"
  case beverage = "음료"
  case dessert = "디저트"
  case food = "푸드"

  public var id: String { rawValue }
  public var title: String { rawValue }
}

public enum MenuStatus: CaseIterable, Hashable {
  case safe
  case warning
  case danger

  public var text: String {
    switch self {
    case .safe:
      return "안전"
    case .warning:
      return "주의"
    case .danger:
      return "위험"
    }
  }
}

public struct MenuItem: Identifiable, Hashable {
  public let id: UUID
  public let name: String
  public let price: String
  public let category: MenuCategory
  public let status: MenuStatus
  public let costRate: String
  public let marginRate: String
  public let costAmount: String
  public let contribution: String
  public let ingredients: [IngredientItem]
  public let totalIngredientCost: String

  public init(
    id: UUID = UUID(),
    name: String,
    price: String,
    category: MenuCategory,
    status: MenuStatus,
    costRate: String,
    marginRate: String,
    costAmount: String,
    contribution: String,
    ingredients: [IngredientItem],
    totalIngredientCost: String
  ) {
    self.id = id
    self.name = name
    self.price = price
    self.category = category
    self.status = status
    self.costRate = costRate
    self.marginRate = marginRate
    self.costAmount = costAmount
    self.contribution = contribution
    self.ingredients = ingredients
    self.totalIngredientCost = totalIngredientCost
  }
}

public struct IngredientItem: Identifiable, Hashable {
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
