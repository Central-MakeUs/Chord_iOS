import ComposableArchitecture
import DataLayer
import Foundation
import UIKit

@Reducer
public struct AICoachFeature {
  public struct State: Equatable {
    var recommendedStrategies: [RecommendedStrategy] = []
    var selectedYear: Int
    var selectedMonth: Int
    var selectedFilter: StrategyFilter = .completed
    var strategyHistory: [StrategyHistoryItem] = []
    var selectedDetail: StrategyDetailItem?
    var isDetailSheetPresented = false
    var completionResult: StrategyCompletionResult?
    var isCompletionResultPresented = false
    var pendingCompletionDetail: StrategyDetailItem?
    var pendingStartToast = false
    var isLoading = false
    var error: String?
    var showToast = false
    var toastMessage = ""

    public init() {
      let now = Date()
      let calendar = Calendar(identifier: .gregorian)
      self.selectedYear = calendar.component(.year, from: now)
      self.selectedMonth = calendar.component(.month, from: now)
    }

    var monthDisplayText: String {
      "\(selectedYear % 100)년 \(selectedMonth)월"
    }
  }

  public enum Action: Equatable {
    case onAppear
    case backTapped
    case previousMonthTapped
    case nextMonthTapped
    case filterSelected(StrategyFilter)
    case strategyTapped(Int)
    case historyTapped(Int)
    case detailExecuteTapped
    case weeklyStrategiesResponse(Result<[RecommendedStrategy], Error>)
    case savedStrategiesResponse(Result<[StrategyHistoryItem], Error>)
    case strategyDetailResponse(Result<StrategyDetailItem, Error>)
    case detailSheetPresentedChanged(Bool)
    case completionResultPresentedChanged(Bool)
    case showToastChanged(Bool)
    case strategyMutationCompleted(Result<String?, Error>)

    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case (.backTapped, .backTapped): return true
      case (.previousMonthTapped, .previousMonthTapped): return true
      case (.nextMonthTapped, .nextMonthTapped): return true
      case let (.filterSelected(l), .filterSelected(r)): return l == r
      case let (.strategyTapped(l), .strategyTapped(r)): return l == r
      case let (.historyTapped(l), .historyTapped(r)): return l == r
      case (.detailExecuteTapped, .detailExecuteTapped): return true
      case let (.weeklyStrategiesResponse(.success(l)), .weeklyStrategiesResponse(.success(r))): return l == r
      case (.weeklyStrategiesResponse(.failure), .weeklyStrategiesResponse(.failure)): return true
      case let (.savedStrategiesResponse(.success(l)), .savedStrategiesResponse(.success(r))): return l == r
      case (.savedStrategiesResponse(.failure), .savedStrategiesResponse(.failure)): return true
      case let (.strategyDetailResponse(.success(l)), .strategyDetailResponse(.success(r))): return l == r
      case (.strategyDetailResponse(.failure), .strategyDetailResponse(.failure)): return true
      case let (.detailSheetPresentedChanged(l), .detailSheetPresentedChanged(r)): return l == r
      case let (.completionResultPresentedChanged(l), .completionResultPresentedChanged(r)): return l == r
      case let (.showToastChanged(l), .showToastChanged(r)): return l == r
      case let (.strategyMutationCompleted(.success(l)), .strategyMutationCompleted(.success(r))): return l == r
      case (.strategyMutationCompleted(.failure), .strategyMutationCompleted(.failure)): return true
      default: return false
      }
    }
  }

  public init() {}

  @Dependency(\.insightRepository) var insightRepository

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .merge(
          loadWeeklyStrategies(),
          loadSavedStrategies(year: state.selectedYear, month: state.selectedMonth, filter: state.selectedFilter)
        )

      case .backTapped:
        return .none

      case .previousMonthTapped:
        if state.selectedMonth == 1 {
          state.selectedMonth = 12
          state.selectedYear -= 1
        } else {
          state.selectedMonth -= 1
        }

        state.isLoading = true
        return loadSavedStrategies(year: state.selectedYear, month: state.selectedMonth, filter: state.selectedFilter)

      case .nextMonthTapped:
        if state.selectedMonth == 12 {
          state.selectedMonth = 1
          state.selectedYear += 1
        } else {
          state.selectedMonth += 1
        }

        state.isLoading = true
        return loadSavedStrategies(year: state.selectedYear, month: state.selectedMonth, filter: state.selectedFilter)

      case let .filterSelected(filter):
        let shouldHaptic = state.selectedFilter != filter
        state.selectedFilter = filter

        state.isLoading = true
        let loadEffect = loadSavedStrategies(year: state.selectedYear, month: state.selectedMonth, filter: state.selectedFilter)
        return shouldHaptic ? .merge(loadEffect, selectionHaptic()) : loadEffect

      case let .strategyTapped(id):
        guard let strategy = state.recommendedStrategies.first(where: { $0.id == id }) else { return .none }

        switch strategy.status {
        case .notStarted:
          state.isLoading = true
          return loadStrategyDetail(
            strategyId: strategy.strategyId,
            type: strategy.type,
            fallbackTitle: strategy.title
          )
        case .inProgress:
          state.isLoading = true
          return loadStrategyDetail(
            strategyId: strategy.strategyId,
            type: strategy.type,
            fallbackTitle: strategy.title
          )
        case .completed:
          state.isLoading = true
          return loadStrategyDetail(
            strategyId: strategy.strategyId,
            type: strategy.type,
            fallbackTitle: strategy.title
          )
        }

      case let .historyTapped(id):
        guard let strategy = state.strategyHistory.first(where: { $0.id == id }) else { return .none }

        state.isLoading = true
        return loadStrategyDetail(
          strategyId: strategy.strategyId,
          type: strategy.type,
          fallbackTitle: strategy.title
        )

      case .detailExecuteTapped:
        guard let detail = state.selectedDetail else { return .none }

        switch detail.status {
        case .notStarted:
          state.isDetailSheetPresented = false
          state.selectedDetail = nil
          state.pendingStartToast = true
          return mutateStrategy {
            try await insightRepository.startStrategy(detail.strategyId, detail.type)
            return nil
          }
        case .inProgress:
          state.pendingCompletionDetail = detail
          state.isLoading = true
          return mutateStrategy {
            let response = try await insightRepository.completeStrategy(detail.strategyId, detail.type)
            return response.completionPhrase
          }
        case .completed:
          return .none
        }

      case let .weeklyStrategiesResponse(.success(items)):
        state.recommendedStrategies = items
        state.isLoading = false
        return .none

      case let .weeklyStrategiesResponse(.failure(error)):
        state.error = error.localizedDescription
        state.isLoading = false
        return .none

      case let .savedStrategiesResponse(.success(items)):
        state.strategyHistory = items
        state.isLoading = false
        return .none

      case let .savedStrategiesResponse(.failure(error)):
        state.error = error.localizedDescription
        state.isLoading = false
        return .none

      case let .strategyDetailResponse(.success(detail)):
        state.selectedDetail = detail
        state.isDetailSheetPresented = true
        state.isLoading = false
        return .none

      case let .strategyDetailResponse(.failure(error)):
        state.error = error.localizedDescription
        state.isLoading = false
        return .none

      case let .detailSheetPresentedChanged(isPresented):
        state.isDetailSheetPresented = isPresented
        if !isPresented {
          state.selectedDetail = nil
        }
        return .none

      case let .completionResultPresentedChanged(isPresented):
        state.isCompletionResultPresented = isPresented
        if !isPresented {
          state.completionResult = nil
          state.isDetailSheetPresented = false
          state.selectedDetail = nil
        }
        return .none

      case let .showToastChanged(isPresented):
        state.showToast = isPresented
        return .none

      case let .strategyMutationCompleted(.success(message)):
        if let pendingDetail = state.pendingCompletionDetail {
          state.completionResult = makeCompletionResult(from: pendingDetail, completionPhrase: message)
          state.isCompletionResultPresented = true
          state.pendingCompletionDetail = nil
        } else if state.pendingStartToast {
          state.pendingStartToast = false
          state.toastMessage = "실행 중인 전략을 추가했어요"
          state.showToast = true
        } else if let message, !message.isEmpty {
          state.error = message
        }
        state.isLoading = true
        return .merge(
          loadWeeklyStrategies(),
          loadSavedStrategies(year: state.selectedYear, month: state.selectedMonth, filter: state.selectedFilter)
        )

      case let .strategyMutationCompleted(.failure(error)):
        state.pendingCompletionDetail = nil
        state.pendingStartToast = false
        state.error = error.localizedDescription
        state.isLoading = false
        return .none
      }
    }
  }

  private func loadWeeklyStrategies() -> Effect<Action> {
    .run { [insightRepository] send in
      let now = Date()
      let (year, month, weekOfMonth) = calendarComponents(from: now)
      let result = await Result {
        let response = try await insightRepository.fetchWeeklyStrategies(year, month, weekOfMonth)
        return response.map {
          let title = $0.title ?? $0.menuName ?? $0.summary ?? "전략"
          let description = $0.summary ?? $0.detail ?? ""

          return RecommendedStrategy(
            id: $0.strategyId,
            strategyId: $0.strategyId,
            type: $0.type,
            status: StrategyStatus.from(state: $0.state),
            title: title,
            description: description
          )
        }
      }
      await send(.weeklyStrategiesResponse(result))
    }
  }

  private func loadSavedStrategies(year: Int, month: Int, filter: StrategyFilter) -> Effect<Action> {
    .run { [insightRepository] send in
      let result = await Result {
        let response = try await insightRepository.fetchSavedStrategies(year, month, filter == .completed)
        return response.map {
          let title = $0.title ?? $0.menuName ?? $0.summary ?? "전략"
          let description = $0.summary ?? $0.detail ?? ""

          return StrategyHistoryItem(
            id: $0.strategyId,
            strategyId: $0.strategyId,
            type: $0.type,
            weekLabel: "\($0.month)월 \($0.weekOfMonth)주차",
            title: title,
            description: description
          )
        }
      }
      await send(.savedStrategiesResponse(result))
    }
  }

  private func mutateStrategy(
    task: @escaping @Sendable () async throws -> String?
  ) -> Effect<Action> {
    .run { send in
      let result = await Result { try await task() }
      await send(.strategyMutationCompleted(result))
    }
  }

  private func selectionHaptic() -> Effect<Action> {
    .run { _ in
      await MainActor.run {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
      }
    }
  }

  private func loadStrategyDetail(
    strategyId: Int,
    type: String,
    fallbackTitle: String
  ) -> Effect<Action> {
    .run { [insightRepository] send in
      let result = await Result {
        let detail = try await insightRepository.fetchStrategyDetail(strategyId, type)
        let weekLabel = "\(detail.month)월 \(detail.weekOfMonth)주차"
        let primaryMenu = detail.menuName ?? detail.menuNames.first
        let menuText: String
        if detail.menuNames.isEmpty {
          menuText = primaryMenu ?? ""
        } else {
          menuText = detail.menuNames.joined(separator: ", ")
        }

        return StrategyDetailItem(
          id: detail.strategyId,
          strategyId: detail.strategyId,
          type: detail.type,
          status: StrategyStatus.from(state: detail.state),
          weekLabel: weekLabel,
          title: detail.summary.isEmpty ? fallbackTitle : detail.summary,
          summary: detail.summary,
          detail: detail.detail,
          guide: detail.guide,
          expectedEffect: detail.expectedEffect,
          menuText: menuText,
          costRate: detail.costRate
        )
      }
      await send(.strategyDetailResponse(result))
    }
  }

  private func makeCompletionResult(
    from detail: StrategyDetailItem,
    completionPhrase: String?
  ) -> StrategyCompletionResult {
    let menuName = detail.menuText
      .split(separator: ",")
      .first
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .flatMap { $0.isEmpty ? nil : $0 } ?? "해당 메뉴"

    return StrategyCompletionResult(
      strategyType: detail.type,
      menuName: menuName,
      completionPhrase: completionPhrase
    )
  }

  private func calendarComponents(from date: Date) -> (Int, Int, Int) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "ko_KR")
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    calendar.firstWeekday = 2
    calendar.minimumDaysInFirstWeek = 4
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let weekOfMonth = calendar.component(.weekOfMonth, from: date)
    return (year, month, weekOfMonth)
  }
}

public enum StrategyStatus: Equatable {
  case inProgress
  case notStarted
  case completed

  static func from(state: String) -> StrategyStatus {
    switch state {
    case "ONGOING": return .inProgress
    case "COMPLETED": return .completed
    default: return .notStarted
    }
  }

  var displayText: String {
    switch self {
    case .inProgress: return "진행중"
    case .notStarted: return "진행전"
    case .completed: return "완료"
    }
  }
}

public enum StrategyFilter: Equatable, CaseIterable {
  case completed
  case incomplete

  var displayText: String {
    switch self {
    case .completed: return "실행 완료"
    case .incomplete: return "미완료"
    }
  }
}

public struct StrategyCompletionResult: Equatable {
  public let strategyType: String
  public let menuName: String
  public let completionPhrase: String?
}

public struct RecommendedStrategy: Equatable, Identifiable {
  public let id: Int
  public let strategyId: Int
  public let type: String
  public let status: StrategyStatus
  public let title: String
  public let description: String
}

public struct StrategyHistoryItem: Equatable, Identifiable {
  public let id: Int
  public let strategyId: Int
  public let type: String
  public let weekLabel: String
  public let title: String
  public let description: String
}

public struct StrategyDetailItem: Equatable, Identifiable {
  public let id: Int
  public let strategyId: Int
  public let type: String
  public let status: StrategyStatus
  public let weekLabel: String
  public let title: String
  public let summary: String
  public let detail: String
  public let guide: String
  public let expectedEffect: String
  public let menuText: String
  public let costRate: Double?
}
