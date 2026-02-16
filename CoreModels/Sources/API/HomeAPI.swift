import Foundation

public struct HomeMenusResponse: Codable, Equatable {
  public let numOfDangerMenus: Int
  public let avgCostRate: AvgCostRateResponse
  public let avgMarginRate: Double

  public init(numOfDangerMenus: Int, avgCostRate: AvgCostRateResponse, avgMarginRate: Double) {
    self.numOfDangerMenus = numOfDangerMenus
    self.avgCostRate = avgCostRate
    self.avgMarginRate = avgMarginRate
  }
}

public struct AvgCostRateResponse: Codable, Equatable {
  public let avgCostRate: Double
  public let marginGradeCode: String

  public init(avgCostRate: Double, marginGradeCode: String) {
    self.avgCostRate = avgCostRate
    self.marginGradeCode = marginGradeCode
  }
}

public struct HomeStrategiesResponse: Codable, Equatable {
  public let strategies: [HomeStrategyBriefResponse]

  public init(strategies: [HomeStrategyBriefResponse]) {
    self.strategies = strategies
  }
}

public struct HomeStrategyBriefResponse: Codable, Equatable {
  public let menuId: Int?
  public let title: String
  public let strategyId: Int
  public let state: String
  public let type: String
  public let summary: String
  public let createdAt: String

  public init(
    menuId: Int? = nil,
    title: String,
    strategyId: Int,
    state: String,
    type: String,
    summary: String,
    createdAt: String
  ) {
    self.menuId = menuId
    self.title = title
    self.strategyId = strategyId
    self.state = state
    self.type = type
    self.summary = summary
    self.createdAt = createdAt
  }

  enum CodingKeys: String, CodingKey {
    case menuId
    case title
    case menuName
    case strategyId
    case state
    case type
    case summary
    case createdAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    menuId = try container.decodeIfPresent(Int.self, forKey: .menuId)
    strategyId = try container.decode(Int.self, forKey: .strategyId)
    state = try container.decode(String.self, forKey: .state)
    type = try container.decode(String.self, forKey: .type)
    title =
      try container.decodeIfPresent(String.self, forKey: .title)
      ?? container.decodeIfPresent(String.self, forKey: .menuName)
      ?? ""
    summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
    createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(menuId, forKey: .menuId)
    try container.encode(title, forKey: .title)
    try container.encode(strategyId, forKey: .strategyId)
    try container.encode(state, forKey: .state)
    try container.encode(type, forKey: .type)
    try container.encode(summary, forKey: .summary)
    try container.encode(createdAt, forKey: .createdAt)
  }
}
