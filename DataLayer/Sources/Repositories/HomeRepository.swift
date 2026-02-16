import ComposableArchitecture
import CoreModels
import Foundation

public struct DashboardStats: Equatable, Sendable {
  public let averageCostRate: String
  public let averageCostRateStatus: MenuStatus
  public let contributionMarginRate: String
  public let contributionMarginRateStatus: MenuStatus
  public let diagnosisNeededCount: Int
  
  public init(
    averageCostRate: String,
    averageCostRateStatus: MenuStatus,
    contributionMarginRate: String,
    contributionMarginRateStatus: MenuStatus,
    diagnosisNeededCount: Int
  ) {
    self.averageCostRate = averageCostRate
    self.averageCostRateStatus = averageCostRateStatus
    self.contributionMarginRate = contributionMarginRate
    self.contributionMarginRateStatus = contributionMarginRateStatus
    self.diagnosisNeededCount = diagnosisNeededCount
  }
}

public struct StrategyGuideItem: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let summary: String
  public let title: String
  
  public init(id: UUID = UUID(), summary: String, title: String) {
    self.id = id
    self.summary = summary
    self.title = title
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
      let apiClient = APIClient()
      let response: BaseResponse<HomeMenusResponse> = try await apiClient.request(
        path: "/api/v1/home/menus",
        method: .get
      )
      guard let data = response.data else { throw APIError.decodingError("Missing data") }

      let avgCostRate = percentString(from: data.avgCostRate.avgCostRate)
      let avgMarginRate = percentString(from: data.avgMarginRate)
      let marginStatus = MenuStatus.from(marginGradeCode: data.avgCostRate.marginGradeCode)

      return DashboardStats(
        averageCostRate: avgCostRate,
        averageCostRateStatus: marginStatus,
        contributionMarginRate: avgMarginRate,
        contributionMarginRateStatus: marginStatus,
        diagnosisNeededCount: data.numOfDangerMenus
      )
    },
    fetchStrategyGuides: {
      let apiClient = APIClient()
      let (year, month, weekOfMonth) = currentYearMonthWeek()
      let response: BaseResponse<HomeStrategiesResponse> = try await apiClient.request(
        path: "/api/v1/home/insights",
        method: .get,
        queryItems: [
          URLQueryItem(name: "year", value: String(year)),
          URLQueryItem(name: "month", value: String(month)),
          URLQueryItem(name: "weekOfMonth", value: String(weekOfMonth))
        ]
      )
      guard let data = response.data else { return [] }

      return data.strategies.map {
        StrategyGuideItem(
          summary: $0.summary,
          title: $0.title
        )
      }
    }
  )
  
  public static let previewValue = HomeRepository(
    fetchDashboardStats: {
      try await Task.sleep(for: .milliseconds(100))
      return DashboardStats(
        averageCostRate: "28.5%",
        averageCostRateStatus: .safe,
        contributionMarginRate: "+12%",
        contributionMarginRateStatus: .normal,
        diagnosisNeededCount: 3
      )
    },
    fetchStrategyGuides: {
      try await Task.sleep(for: .milliseconds(100))
      return [
        StrategyGuideItem(
          summary: "원가율 35% 유지 가능해요",
          title: "바닐라 라떼"
        ),
        StrategyGuideItem(
          summary: "단가가 18% 상승했어요",
          title: "우유"
        ),
        StrategyGuideItem(
          summary: "원가율 35% 유지 가능해요",
          title: "레몬티"
        )
      ]
    }
  )
  
  public static let testValue = HomeRepository(
    fetchDashboardStats: {
      DashboardStats(
        averageCostRate: "0%",
        averageCostRateStatus: .normal,
        contributionMarginRate: "0%",
        contributionMarginRateStatus: .normal,
        diagnosisNeededCount: 0
      )
    },
    fetchStrategyGuides: { [] }
  )
}

private func percentString(from value: Double) -> String {
  if value.truncatingRemainder(dividingBy: 1) == 0 {
    return "\(Int(value))%"
  }
  return String(format: "%.1f%%", value)
}

private func currentYearMonthWeek() -> (Int, Int, Int) {
  var calendar = Calendar(identifier: .gregorian)
  calendar.locale = Locale(identifier: "ko_KR")
  calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
  calendar.firstWeekday = 2
  calendar.minimumDaysInFirstWeek = 4

  let now = Date()
  let year = calendar.component(.year, from: now)
  let month = calendar.component(.month, from: now)
  let weekOfMonth = calendar.component(.weekOfMonth, from: now)
  return (year, month, weekOfMonth)
}


public extension DependencyValues {
  var homeRepository: HomeRepository {
    get { self[HomeRepository.self] }
    set { self[HomeRepository.self] = newValue }
  }
}
