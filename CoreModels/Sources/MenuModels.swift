import Foundation

public enum MenuCategory: String, CaseIterable, Identifiable, Hashable {
  case all = "전체"
  case beverage = "음료"
  case dessert = "디저트"
  case food = "푸드"

  public var id: String { rawValue }
  public var title: String { rawValue }
  
  public var serverCode: String? {
    switch self {
    case .all: return nil
    case .beverage: return "BEVERAGE"
    case .dessert: return "DESSERT"
    case .food: return "FOOD"
    }
  }
}

public enum MenuStatus: CaseIterable, Hashable {
  case safe
  case normal
  case warning
  case danger

  public var text: String {
    switch self {
    case .safe:
      return "안정"
    case .normal:
      return "보통"
    case .warning:
      return "주의"
    case .danger:
      return "위험"
    }
  }

  public static func from(marginGradeCode: String) -> MenuStatus {
    switch marginGradeCode.uppercased() {
    case "SAFE": return .safe
    case "NORMAL": return .normal
    case "WARNING", "CAUTION": return .warning
    case "DANGER": return .danger
    default: return .normal
    }
  }
}

public struct MenuItem: Identifiable, Hashable {
  public let id: UUID
  public let apiId: Int?
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
  public let recommendedPrice: String?
  public let workTime: Int?

  public init(
    id: UUID = UUID(),
    apiId: Int? = nil,
    name: String,
    price: String,
    category: MenuCategory,
    status: MenuStatus,
    costRate: String,
    marginRate: String,
    costAmount: String,
    contribution: String,
    ingredients: [IngredientItem],
    totalIngredientCost: String,
    recommendedPrice: String? = nil,
    workTime: Int? = nil
  ) {
    self.id = id
    self.apiId = apiId
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
    self.recommendedPrice = recommendedPrice
    self.workTime = workTime
  }
  
  public var workTimeText: String {
    guard let seconds = workTime else { return "-" }
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    
    if minutes > 0 && remainingSeconds > 0 {
      return "\(minutes)분 \(remainingSeconds)초"
    } else if minutes > 0 {
      return "\(minutes)분"
    } else {
      return "\(remainingSeconds)초"
    }
  }
}

public struct IngredientItem: Identifiable, Hashable {
  public let id: UUID
  public let recipeId: Int?
  public let ingredientId: Int?
  public let name: String
  public let amount: String
  public let price: String

  public init(
    id: UUID = UUID(),
    recipeId: Int? = nil,
    ingredientId: Int? = nil,
    name: String,
    amount: String,
    price: String
  ) {
    self.id = id
    self.recipeId = recipeId
    self.ingredientId = ingredientId
    self.name = name
    self.amount = amount
    self.price = price
  }
}
