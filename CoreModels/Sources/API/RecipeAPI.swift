import Foundation

public struct RecipeResponse: Codable, Equatable {
  public let recipeId: Int
  public let menuId: Int
  public let ingredientId: Int
  public let ingredientName: String
  public let amount: Double
  public let unitCode: String
  public let price: Double
  
  public init(
    recipeId: Int,
    menuId: Int,
    ingredientId: Int,
    ingredientName: String,
    amount: Double,
    unitCode: String,
    price: Double
  ) {
    self.recipeId = recipeId
    self.menuId = menuId
    self.ingredientId = ingredientId
    self.ingredientName = ingredientName
    self.amount = amount
    self.unitCode = unitCode
    self.price = price
  }
}

public struct RecipeListResponse: Codable, Equatable {
  public let recipes: [RecipeResponse]
  public let totalCost: Double
  
  public init(recipes: [RecipeResponse], totalCost: Double) {
    self.recipes = recipes
    self.totalCost = totalCost
  }
}

public struct RecipeCreateRequest: Codable, Equatable {
  public let ingredientId: Int
  public let amount: Double
  
  public init(ingredientId: Int, amount: Double) {
    self.ingredientId = ingredientId
    self.amount = amount
  }
}

public struct NewRecipeCreateRequest: Codable, Equatable {
  public let amount: Double
  public let usageAmount: Double
  public let price: Double
  public let unitCode: String
  public let ingredientCategoryCode: String
  public let ingredientName: String
  public let supplier: String?
  
  public init(
    amount: Double,
    usageAmount: Double,
    price: Double,
    unitCode: String,
    ingredientCategoryCode: String,
    ingredientName: String,
    supplier: String? = nil
  ) {
    self.amount = amount
    self.usageAmount = usageAmount
    self.price = price
    self.unitCode = unitCode
    self.ingredientCategoryCode = ingredientCategoryCode
    self.ingredientName = ingredientName
    self.supplier = supplier
  }
}

public struct AmountUpdateRequest: Codable, Equatable {
  public let amount: Double
  
  public init(amount: Double) {
    self.amount = amount
  }
}

public struct DeleteRecipesRequest: Codable, Equatable {
  public let recipeIds: [Int]
  
  public init(recipeIds: [Int]) {
    self.recipeIds = recipeIds
  }
}

public struct RecipeTemplateResponse: Codable, Equatable {
  public let ingredientName: String
  public let defaultUsageAmount: Double
  public let defaultPrice: Double
  public let unitCode: String
  
  public init(
    ingredientName: String,
    defaultUsageAmount: Double,
    defaultPrice: Double,
    unitCode: String
  ) {
    self.ingredientName = ingredientName
    self.defaultUsageAmount = defaultUsageAmount
    self.defaultPrice = defaultPrice
    self.unitCode = unitCode
  }
}
