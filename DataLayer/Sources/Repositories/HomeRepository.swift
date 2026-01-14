import ComposableArchitecture
import Foundation

public struct DashboardStats: Equatable, Sendable {
  public let averageCostRate: String
  public let averageCostRateDescription: String
  public let contributionMarginRate: String
  public let contributionMarginRateDescription: String
  public let diagnosisNeededCount: Int
  
  public init(
    averageCostRate: String,
    averageCostRateDescription: String,
    contributionMarginRate: String,
    contributionMarginRateDescription: String,
    diagnosisNeededCount: Int
  ) {
    self.averageCostRate = averageCostRate
    self.averageCostRateDescription = averageCostRateDescription
    self.contributionMarginRate = contributionMarginRate
    self.contributionMarginRateDescription = contributionMarginRateDescription
    self.diagnosisNeededCount = diagnosisNeededCount
  }
}

public struct StrategyGuideItem: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let summary: String
  public let title: String
  public let action: String
  
  public init(id: UUID = UUID(), summary: String, title: String, action: String) {
    self.id = id
    self.summary = summary
    self.title = title
    self.action = action
  }
}

public struct HomeRepository: Sendable {
  public var fetchDashboardStats: @Sendable () async throws -> DashboardStats
  public var fetchStrategyGuides: @Sendable () async throws -> [StrategyGuideItem]
  
  public init(
    fetchDashboardStats: @escaping @Sendable () async throws -> DashboardStats,
    fetchStrategyGuides: @escaping @Sendable () async throws -> [StrategyGuideItem]
  ) {
    self.fetchDashboardStats = fetchDashboardStats
    self.fetchStrategyGuides = fetchStrategyGuides
  }
}

extension HomeRepository: DependencyKey {
  public static let liveValue = HomeRepository(
    fetchDashboardStats: {
      try await Task.sleep(for: .milliseconds(300))
      return DashboardStats(
        averageCostRate: "0%",
        averageCostRateDescription: "데이터 없음",
        contributionMarginRate: "0%",
        contributionMarginRateDescription: "데이터 없음",
        diagnosisNeededCount: 0
      )
    },
    fetchStrategyGuides: {
      try await Task.sleep(for: .milliseconds(300))
      return []
    }
  )
  
  public static let previewValue = HomeRepository(
    fetchDashboardStats: {
      try await Task.sleep(for: .milliseconds(100))
      return DashboardStats(
        averageCostRate: "28.5%",
        averageCostRateDescription: "안정적",
        contributionMarginRate: "+12%",
        contributionMarginRateDescription: "지난주 대비 상승",
        diagnosisNeededCount: 3
      )
    },
    fetchStrategyGuides: {
      try await Task.sleep(for: .milliseconds(100))
      return [
        StrategyGuideItem(
          summary: "원가율 35% 유지 가능해요",
          title: "바닐라 라떼",
          action: "판매가 조정"
        ),
        StrategyGuideItem(
          summary: "단가가 18% 상승했어요",
          title: "우유",
          action: "대체 브랜드 알아보기"
        ),
        StrategyGuideItem(
          summary: "원가율 35% 유지 가능해요",
          title: "레몬티",
          action: "시즌 메뉴로 전환"
        )
      ]
    }
  )
  
  public static let testValue = HomeRepository(
    fetchDashboardStats: {
      DashboardStats(
        averageCostRate: "0%",
        averageCostRateDescription: "테스트",
        contributionMarginRate: "0%",
        contributionMarginRateDescription: "테스트",
        diagnosisNeededCount: 0
      )
    },
    fetchStrategyGuides: { [] }
  )
}

public extension DependencyValues {
  var homeRepository: HomeRepository {
    get { self[HomeRepository.self] }
    set { self[HomeRepository.self] = newValue }
  }
}
