import Foundation

public struct CheckDupRequest: Codable, Equatable {
  public let menuName: String
  public let ingredientNames: [String]?
  
  public init(menuName: String, ingredientNames: [String]? = nil) {
    self.menuName = menuName
    self.ingredientNames = ingredientNames
  }
}

public struct CheckDupResponse: Codable, Equatable {
  public let menuNameDuplicate: Bool
  public let dupIngredientNames: [String]?
  
  public init(menuNameDuplicate: Bool, dupIngredientNames: [String]?) {
    self.menuNameDuplicate = menuNameDuplicate
    self.dupIngredientNames = dupIngredientNames
  }
}

public struct TemplateBasicResponse: Codable, Equatable {
  public let templateId: Int
  public let menuName: String
  public let defaultSellingPrice: Double
  public let categoryCode: String
  public let workTime: Int
  
  public init(
    templateId: Int,
    menuName: String,
    defaultSellingPrice: Double,
    categoryCode: String,
    workTime: Int
  ) {
    self.templateId = templateId
    self.menuName = menuName
    self.defaultSellingPrice = defaultSellingPrice
    self.categoryCode = categoryCode
    self.workTime = workTime
  }
}

public struct BaseResponse<T: Codable & Equatable>: Codable, Equatable {
  public let success: Bool
  public let data: T?
  public let timestamp: String?
  
  public init(success: Bool, data: T? = nil, timestamp: String? = nil) {
    self.success = success
    self.data = data
    self.timestamp = timestamp
  }
}

public struct EmptyResponse: Codable, Equatable {
  public init() {}
}

public struct ErrorResponse: Codable, Equatable {
  public let message: String?
  
  public init(message: String?) {
    self.message = message
  }
}
