import Foundation

public struct IngredientResponse: Codable, Equatable {
  public let ingredientId: Int
  public let ingredientCategoryCode: String
  public let ingredientName: String
  public let unitCode: String
  public let baseQuantity: Int
  public let currentUnitPrice: Double
  
  public init(
    ingredientId: Int,
    ingredientCategoryCode: String,
    ingredientName: String,
    unitCode: String,
    baseQuantity: Int,
    currentUnitPrice: Double
  ) {
    self.ingredientId = ingredientId
    self.ingredientCategoryCode = ingredientCategoryCode
    self.ingredientName = ingredientName
    self.unitCode = unitCode
    self.baseQuantity = baseQuantity
    self.currentUnitPrice = currentUnitPrice
  }
}

public struct IngredientMenuResponse: Codable, Equatable, Hashable {
  public let menuName: String
  public let amount: Double
  public let unitCode: String
  
  public init(menuName: String, amount: Double, unitCode: String) {
    self.menuName = menuName
    self.amount = amount
    self.unitCode = unitCode
  }
}

public struct IngredientDetailResponse: Codable, Equatable {
  public let ingredientId: Int
  public let ingredientCategoryCode: String?
  public let ingredientName: String
  public let unitPrice: Double
  public let baseQuantity: Int
  public let unitCode: String
  public let supplier: String?
  public let menus: [IngredientMenuResponse]
  public let originalAmount: Double
  public let originalPrice: Double
  public let isFavorite: Bool
  
  public init(
    ingredientId: Int,
    ingredientCategoryCode: String? = nil,
    ingredientName: String,
    unitPrice: Double,
    baseQuantity: Int,
    unitCode: String,
    supplier: String?,
    menus: [IngredientMenuResponse],
    originalAmount: Double,
    originalPrice: Double,
    isFavorite: Bool
  ) {
    self.ingredientId = ingredientId
    self.ingredientCategoryCode = ingredientCategoryCode
    self.ingredientName = ingredientName
    self.unitPrice = unitPrice
    self.baseQuantity = baseQuantity
    self.unitCode = unitCode
    self.supplier = supplier
    self.menus = menus
    self.originalAmount = originalAmount
    self.originalPrice = originalPrice
    self.isFavorite = isFavorite
  }
}

public struct IngredientCreateRequest: Codable, Equatable {
  public let categoryCode: String
  public let ingredientName: String
  public let unitCode: String
  public let price: Double
  public let amount: Double
  public let supplier: String?
  
  public init(
    categoryCode: String,
    ingredientName: String,
    unitCode: String,
    price: Double,
    amount: Double,
    supplier: String? = nil
  ) {
    self.categoryCode = categoryCode
    self.ingredientName = ingredientName
    self.unitCode = unitCode
    self.price = price
    self.amount = amount
    self.supplier = supplier
  }
}

public struct IngredientUpdateRequest: Codable, Equatable {
  public let category: String
  public let price: Double
  public let amount: Double
  public let unitCode: String
  
  public init(category: String, price: Double, amount: Double, unitCode: String) {
    self.category = category
    self.price = price
    self.amount = amount
    self.unitCode = unitCode
  }
}

public struct SupplierUpdateRequest: Codable, Equatable {
  public let supplier: String?
  
  public init(supplier: String?) {
    self.supplier = supplier
  }
}

public struct IngredientCategoryResponse: Codable, Equatable {
  public let categoryCode: String
  public let categoryName: String
  public let displayOrder: Int
  
  public init(categoryCode: String, categoryName: String, displayOrder: Int) {
    self.categoryCode = categoryCode
    self.categoryName = categoryName
    self.displayOrder = displayOrder
  }
}

public struct PriceHistoryResponse: Codable, Equatable, Identifiable {
  public let historyId: Int
  public let changeDate: String
  public let unitPrice: Double
  public let unitCode: String
  public let baseQuantity: Int
  
  public var id: Int { historyId }
  
  public init(
    historyId: Int,
    changeDate: String,
    unitPrice: Double,
    unitCode: String,
    baseQuantity: Int
  ) {
    self.historyId = historyId
    self.changeDate = changeDate
    self.unitPrice = unitPrice
    self.unitCode = unitCode
    self.baseQuantity = baseQuantity
  }
}

public struct SearchIngredientsResponse: Codable, Equatable {
  public let isTemplate: Bool
  public let templateId: Int?
  public let ingredientId: Int?
  public let ingredientName: String
  
  public init(isTemplate: Bool, templateId: Int?, ingredientId: Int?, ingredientName: String) {
    self.isTemplate = isTemplate
    self.templateId = templateId
    self.ingredientId = ingredientId
    self.ingredientName = ingredientName
  }
}

public struct SearchMyIngredientsResponse: Codable, Equatable {
  public let ingredientId: Int
  public let ingredientName: String
  
  public init(ingredientId: Int, ingredientName: String) {
    self.ingredientId = ingredientId
    self.ingredientName = ingredientName
  }
}
