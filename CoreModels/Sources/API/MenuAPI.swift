import Foundation

public struct MenuResponse: Codable, Equatable {
  public let menuId: Int
  public let menuName: String
  public let sellingPrice: Double
  public let costRate: Double
  public let marginGradeCode: String
  public let marginGradeName: String
  public let marginRate: Double
  
  public init(
    menuId: Int,
    menuName: String,
    sellingPrice: Double,
    costRate: Double,
    marginGradeCode: String,
    marginGradeName: String,
    marginRate: Double
  ) {
    self.menuId = menuId
    self.menuName = menuName
    self.sellingPrice = sellingPrice
    self.costRate = costRate
    self.marginGradeCode = marginGradeCode
    self.marginGradeName = marginGradeName
    self.marginRate = marginRate
  }
}

public struct MenuDetailResponse: Codable, Equatable {
  public let menuId: Int
  public let menuName: String
  public let workTime: Int
  public let sellingPrice: Double
  public let marginRate: Double
  public let totalCost: Double
  public let costRate: Double
  public let contributionMargin: Double
  public let marginGradeCode: String
  public let marginGradeName: String
  public let marginGradeMessage: String
  public let recommendedPrice: Double
  
  public init(
    menuId: Int,
    menuName: String,
    workTime: Int,
    sellingPrice: Double,
    marginRate: Double,
    totalCost: Double,
    costRate: Double,
    contributionMargin: Double,
    marginGradeCode: String,
    marginGradeName: String,
    marginGradeMessage: String,
    recommendedPrice: Double
  ) {
    self.menuId = menuId
    self.menuName = menuName
    self.workTime = workTime
    self.sellingPrice = sellingPrice
    self.marginRate = marginRate
    self.totalCost = totalCost
    self.costRate = costRate
    self.contributionMargin = contributionMargin
    self.marginGradeCode = marginGradeCode
    self.marginGradeName = marginGradeName
    self.marginGradeMessage = marginGradeMessage
    self.recommendedPrice = recommendedPrice
  }
}

public struct MenuCreateRequest: Codable, Equatable {
  public let menuCategoryCode: String
  public let menuName: String
  public let sellingPrice: Double
  public let workTime: Int
  public let recipes: [RecipeCreateRequest]
  public let newRecipes: [NewRecipeCreateRequest]
  
  public init(
    menuCategoryCode: String,
    menuName: String,
    sellingPrice: Double,
    workTime: Int,
    recipes: [RecipeCreateRequest] = [],
    newRecipes: [NewRecipeCreateRequest] = []
  ) {
    self.menuCategoryCode = menuCategoryCode
    self.menuName = menuName
    self.sellingPrice = sellingPrice
    self.workTime = workTime
    self.recipes = recipes
    self.newRecipes = newRecipes
  }
}

public struct MenuNameUpdateRequest: Codable, Equatable {
  public let menuName: String
  
  public init(menuName: String) {
    self.menuName = menuName
  }
}

public struct MenuPriceUpdateRequest: Codable, Equatable {
  public let sellingPrice: Double
  
  public init(sellingPrice: Double) {
    self.sellingPrice = sellingPrice
  }
}

public struct MenuWorktimeUpdateRequest: Codable, Equatable {
  public let workTime: Int
  
  public init(workTime: Int) {
    self.workTime = workTime
  }
}

public struct MenuCategoryUpdateRequest: Codable, Equatable {
  public let category: String
  
  public init(category: String) {
    self.category = category
  }
}

public struct MenuCategoryResponse: Codable, Equatable {
  public let categoryCode: String
  public let categoryName: String
  public let displayOrder: Int
  
  public init(categoryCode: String, categoryName: String, displayOrder: Int) {
    self.categoryCode = categoryCode
    self.categoryName = categoryName
    self.displayOrder = displayOrder
  }
}

public struct SearchMenusResponse: Codable, Equatable {
  public let templateId: Int
  public let menuName: String
  
  public init(templateId: Int, menuName: String) {
    self.templateId = templateId
    self.menuName = menuName
  }
}
