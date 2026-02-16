import ComposableArchitecture
import CoreModels
import Foundation

public struct InsightRepository: Sendable {
  public var fetchWeeklyStrategies: @Sendable (_ year: Int, _ month: Int, _ weekOfMonth: Int) async throws -> [InsightStrategyBriefResponse]
  public var fetchSavedStrategies: @Sendable (_ year: Int, _ month: Int, _ isCompleted: Bool) async throws -> [InsightSavedStrategyResponse]
  public var fetchStrategyDetail: @Sendable (_ strategyId: Int, _ type: String) async throws -> InsightStrategyDetailResponse
  public var startStrategy: @Sendable (_ strategyId: Int, _ type: String) async throws -> Void
  public var completeStrategy: @Sendable (_ strategyId: Int, _ type: String) async throws -> InsightCompletionPhraseResponse

  public init(
    fetchWeeklyStrategies: @escaping @Sendable (_ year: Int, _ month: Int, _ weekOfMonth: Int) async throws -> [InsightStrategyBriefResponse],
    fetchSavedStrategies: @escaping @Sendable (_ year: Int, _ month: Int, _ isCompleted: Bool) async throws -> [InsightSavedStrategyResponse],
    fetchStrategyDetail: @escaping @Sendable (_ strategyId: Int, _ type: String) async throws -> InsightStrategyDetailResponse,
    startStrategy: @escaping @Sendable (_ strategyId: Int, _ type: String) async throws -> Void,
    completeStrategy: @escaping @Sendable (_ strategyId: Int, _ type: String) async throws -> InsightCompletionPhraseResponse
  ) {
    self.fetchWeeklyStrategies = fetchWeeklyStrategies
    self.fetchSavedStrategies = fetchSavedStrategies
    self.fetchStrategyDetail = fetchStrategyDetail
    self.startStrategy = startStrategy
    self.completeStrategy = completeStrategy
  }
}

extension InsightRepository: DependencyKey {
  public static let liveValue: InsightRepository = {
    let apiClient = APIClient()

    return InsightRepository(
      fetchWeeklyStrategies: { year, month, weekOfMonth in
        let response: BaseResponse<[InsightStrategyBriefResponse]> = try await apiClient.request(
          path: "/api/v1/insights/strategies/weekly",
          method: .get,
          queryItems: [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month)),
            URLQueryItem(name: "weekOfMonth", value: String(weekOfMonth))
          ]
        )
        return response.data ?? []
      },
      fetchSavedStrategies: { year, month, isCompleted in
        let response: BaseResponse<[InsightSavedStrategyResponse]> = try await apiClient.request(
          path: "/api/v1/insights/strategies/saved",
          method: .get,
          queryItems: [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "month", value: String(month)),
            URLQueryItem(name: "isCompleted", value: String(isCompleted))
          ]
        )
        return response.data ?? []
      },
      fetchStrategyDetail: { strategyId, type in
        switch type {
        case "DANGER":
          let response: BaseResponse<InsightDangerStrategyDetailResponse> = try await apiClient.request(
            path: "/api/v1/insights/strategies/danger/\(strategyId)",
            method: .get
          )
          guard let data = response.data else { throw APIError.decodingError("Missing data") }
          return InsightStrategyDetailResponse(
            strategyId: data.strategyId,
            type: data.type,
            state: data.state,
            summary: data.summary,
            detail: data.detail,
            guide: data.guide,
            expectedEffect: data.expectedEffect,
            saved: data.saved,
            startDate: data.startDate,
            completionDate: data.completionDate,
            year: data.year,
            month: data.month,
            weekOfMonth: data.weekOfMonth,
            menuName: data.menuName,
            menuNames: [data.menuName],
            costRate: data.costRate
          )
        case "CAUTION":
          let response: BaseResponse<InsightCautionStrategyDetailResponse> = try await apiClient.request(
            path: "/api/v1/insights/strategies/caution/\(strategyId)",
            method: .get
          )
          guard let data = response.data else { throw APIError.decodingError("Missing data") }
          return InsightStrategyDetailResponse(
            strategyId: data.strategyId,
            type: data.type,
            state: data.state,
            summary: data.summary,
            detail: data.detail,
            guide: data.guide,
            expectedEffect: data.expectedEffect,
            saved: data.saved,
            startDate: data.startDate,
            completionDate: data.completionDate,
            year: data.year,
            month: data.month,
            weekOfMonth: data.weekOfMonth,
            menuName: data.menuName,
            menuNames: [data.menuName],
            costRate: data.costRate
          )
        case "HIGH_MARGIN":
          let response: BaseResponse<InsightHighMarginStrategyDetailResponse> = try await apiClient.request(
            path: "/api/v1/insights/strategies/high-margin/\(strategyId)",
            method: .get
          )
          guard let data = response.data else { throw APIError.decodingError("Missing data") }
          return InsightStrategyDetailResponse(
            strategyId: data.strategyId,
            type: data.type,
            state: data.state,
            summary: data.summary,
            detail: data.detail,
            guide: data.guide,
            expectedEffect: data.expectedEffect,
            saved: data.saved,
            startDate: data.startDate,
            completionDate: data.completionDate,
            year: data.year,
            month: data.month,
            weekOfMonth: data.weekOfMonth,
            menuName: nil,
            menuNames: data.menuNames,
            costRate: nil
          )
        default:
          throw APIError.decodingError("Unsupported strategy type: \(type)")
        }
      },
      startStrategy: { strategyId, type in
        try await apiClient.requestVoid(
          path: "/api/v1/insights/strategies/\(strategyId)/start",
          method: .patch,
          queryItems: [
            URLQueryItem(name: "type", value: type)
          ]
        )
      },
      completeStrategy: { strategyId, type in
        let response: BaseResponse<InsightCompletionPhraseResponse> = try await apiClient.request(
          path: "/api/v1/insights/strategies/\(strategyId)/complete",
          method: .patch,
          queryItems: [
            URLQueryItem(name: "type", value: type)
          ]
        )
        guard let data = response.data else { throw APIError.decodingError("Missing data") }
        return data
      }
    )
  }()

  public static let previewValue = InsightRepository(
    fetchWeeklyStrategies: { _, _, _ in [] },
    fetchSavedStrategies: { _, _, _ in [] },
    fetchStrategyDetail: { _, _ in
      InsightStrategyDetailResponse(
        strategyId: 0,
        type: "DANGER",
        state: "BEFORE",
        summary: "",
        detail: "",
        guide: "",
        expectedEffect: "",
        saved: false,
        startDate: nil,
        completionDate: nil,
        year: 0,
        month: 0,
        weekOfMonth: 0,
        menuName: nil,
        menuNames: [],
        costRate: nil
      )
    },
    startStrategy: { _, _ in },
    completeStrategy: { _, _ in InsightCompletionPhraseResponse(completionPhrase: "") }
  )

  public static let testValue = InsightRepository(
    fetchWeeklyStrategies: { _, _, _ in [] },
    fetchSavedStrategies: { _, _, _ in [] },
    fetchStrategyDetail: { _, _ in
      InsightStrategyDetailResponse(
        strategyId: 0,
        type: "DANGER",
        state: "BEFORE",
        summary: "",
        detail: "",
        guide: "",
        expectedEffect: "",
        saved: false,
        startDate: nil,
        completionDate: nil,
        year: 0,
        month: 0,
        weekOfMonth: 0,
        menuName: nil,
        menuNames: [],
        costRate: nil
      )
    },
    startStrategy: { _, _ in },
    completeStrategy: { _, _ in InsightCompletionPhraseResponse(completionPhrase: "") }
  )
}

public extension DependencyValues {
  var insightRepository: InsightRepository {
    get { self[InsightRepository.self] }
    set { self[InsightRepository.self] = newValue }
  }
}
