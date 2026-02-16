import Foundation

public struct InsightStrategyBriefResponse: Codable, Equatable {
  public let menuId: Int?
  public let strategyId: Int
  public let state: String
  public let type: String
  public let title: String?
  public let menuName: String?
  public let summary: String?
  public let detail: String?
  public let startDate: String?
  public let completionDate: String?
  public let createdAt: String?

  public init(
    menuId: Int? = nil,
    strategyId: Int,
    state: String,
    type: String,
    title: String? = nil,
    menuName: String? = nil,
    summary: String? = nil,
    detail: String? = nil,
    startDate: String?,
    completionDate: String?,
    createdAt: String?
  ) {
    self.menuId = menuId
    self.strategyId = strategyId
    self.state = state
    self.type = type
    self.title = title
    self.menuName = menuName
    self.summary = summary
    self.detail = detail
    self.startDate = startDate
    self.completionDate = completionDate
    self.createdAt = createdAt
  }
}

public struct InsightSavedStrategyResponse: Codable, Equatable {
  public let strategyId: Int
  public let state: String
  public let type: String
  public let title: String?
  public let menuName: String?
  public let summary: String?
  public let detail: String?
  public let year: Int
  public let month: Int
  public let weekOfMonth: Int
  public let menuId: Int?
  public let strategyDate: String?
  public let createdAt: String?

  public init(
    strategyId: Int,
    state: String,
    type: String,
    title: String? = nil,
    menuName: String? = nil,
    summary: String? = nil,
    detail: String? = nil,
    year: Int,
    month: Int,
    weekOfMonth: Int,
    menuId: Int? = nil,
    strategyDate: String? = nil,
    createdAt: String? = nil
  ) {
    self.strategyId = strategyId
    self.state = state
    self.type = type
    self.title = title
    self.menuName = menuName
    self.summary = summary
    self.detail = detail
    self.year = year
    self.month = month
    self.weekOfMonth = weekOfMonth
    self.menuId = menuId
    self.strategyDate = strategyDate
    self.createdAt = createdAt
  }
}

public struct InsightCompletionPhraseResponse: Codable, Equatable {
  public let completionPhrase: String

  public init(completionPhrase: String) {
    self.completionPhrase = completionPhrase
  }
}

public struct InsightDangerStrategyDetailResponse: Codable, Equatable {
  public let strategyId: Int
  public let summary: String
  public let detail: String
  public let guide: String
  public let expectedEffect: String
  public let state: String
  public let saved: Bool
  public let startDate: String?
  public let completionDate: String?
  public let menuId: Int
  public let menuName: String
  public let costRate: Double
  public let type: String
  public let year: Int
  public let month: Int
  public let weekOfMonth: Int
}

public struct InsightCautionStrategyDetailResponse: Codable, Equatable {
  public let strategyId: Int
  public let summary: String
  public let detail: String
  public let guide: String
  public let expectedEffect: String
  public let state: String
  public let saved: Bool
  public let startDate: String?
  public let completionDate: String?
  public let menuId: Int
  public let menuName: String
  public let costRate: Double
  public let type: String
  public let year: Int
  public let month: Int
  public let weekOfMonth: Int
}

public struct InsightHighMarginStrategyDetailResponse: Codable, Equatable {
  public let strategyId: Int
  public let summary: String
  public let detail: String
  public let guide: String
  public let expectedEffect: String
  public let state: String
  public let saved: Bool
  public let startDate: String?
  public let completionDate: String?
  public let type: String
  public let year: Int
  public let month: Int
  public let weekOfMonth: Int
  public let menuNames: [String]
}

public struct InsightStrategyDetailResponse: Equatable {
  public let strategyId: Int
  public let type: String
  public let state: String
  public let summary: String
  public let detail: String
  public let guide: String
  public let expectedEffect: String
  public let saved: Bool
  public let startDate: String?
  public let completionDate: String?
  public let year: Int
  public let month: Int
  public let weekOfMonth: Int
  public let menuName: String?
  public let menuNames: [String]
  public let costRate: Double?

  public init(
    strategyId: Int,
    type: String,
    state: String,
    summary: String,
    detail: String,
    guide: String,
    expectedEffect: String,
    saved: Bool,
    startDate: String?,
    completionDate: String?,
    year: Int,
    month: Int,
    weekOfMonth: Int,
    menuName: String?,
    menuNames: [String],
    costRate: Double?
  ) {
    self.strategyId = strategyId
    self.type = type
    self.state = state
    self.summary = summary
    self.detail = detail
    self.guide = guide
    self.expectedEffect = expectedEffect
    self.saved = saved
    self.startDate = startDate
    self.completionDate = completionDate
    self.year = year
    self.month = month
    self.weekOfMonth = weekOfMonth
    self.menuName = menuName
    self.menuNames = menuNames
    self.costRate = costRate
  }
}
