import ComposableArchitecture
import Foundation

@Reducer
public struct AICoachFeature {
  public struct State: Equatable {
    var recommendedStrategies: [RecommendedStrategy] = []
    var selectedYear: Int = 26
    var selectedMonth: Int = 1
    var selectedFilter: StrategyFilter = .completed
    var strategyHistory: [StrategyHistoryItem] = []
    
    public init() {
      self.recommendedStrategies = [
        RecommendedStrategy(id: UUID(), status: .inProgress, title: "흑임자 두쯔쿠", description: "원가 이상에 대응해보세요"),
        RecommendedStrategy(id: UUID(), status: .notStarted, title: "흑임자 두쯔쿠", description: "원가 이상에 대응해보세요")
      ]
      self.strategyHistory = [
        StrategyHistoryItem(id: UUID(), weekLabel: "1월 5주차", title: "전략 제목이 들어갑니다", description: "전략 내용이 들어갑니다"),
        StrategyHistoryItem(id: UUID(), weekLabel: "1월 4주차", title: "전략 제목이 들어갑니다", description: "전략 내용이 들어갑니다"),
        StrategyHistoryItem(id: UUID(), weekLabel: "1월 3주차", title: "전략 제목이 들어갑니다", description: "전략 내용이 들어갑니다"),
        StrategyHistoryItem(id: UUID(), weekLabel: "1월 2주차", title: "전략 제목이 들어갑니다", description: "전략 내용이 들어갑니다")
      ]
    }
    
    var monthDisplayText: String {
      "\(selectedYear)년 \(selectedMonth)월"
    }
  }

  public enum Action: Equatable {
    case backTapped
    case previousMonthTapped
    case nextMonthTapped
    case filterSelected(StrategyFilter)
    case strategyTapped(UUID)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .backTapped:
        return .none
        
      case .previousMonthTapped:
        if state.selectedMonth == 1 {
          state.selectedMonth = 12
          state.selectedYear -= 1
        } else {
          state.selectedMonth -= 1
        }
        return .none
        
      case .nextMonthTapped:
        if state.selectedMonth == 12 {
          state.selectedMonth = 1
          state.selectedYear += 1
        } else {
          state.selectedMonth += 1
        }
        return .none
        
      case let .filterSelected(filter):
        state.selectedFilter = filter
        return .none
        
      case .strategyTapped:
        return .none
      }
    }
  }
}

public enum StrategyStatus: Equatable {
  case inProgress
  case notStarted
  
  var displayText: String {
    switch self {
    case .inProgress: return "진행중"
    case .notStarted: return "진행전"
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

public struct RecommendedStrategy: Equatable, Identifiable {
  public let id: UUID
  public let status: StrategyStatus
  public let title: String
  public let description: String
}

public struct StrategyHistoryItem: Equatable, Identifiable {
  public let id: UUID
  public let weekLabel: String
  public let title: String
  public let description: String
}
