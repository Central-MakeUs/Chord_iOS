import ComposableArchitecture
import DataLayer

@Reducer
public struct HomeFeature {
  public struct State: Equatable {
    var dashboardStats: DashboardStats?
    var strategyGuides: [StrategyGuideItem] = []
    var isLoading = false
    var error: String?

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case dashboardStatsLoaded(Result<DashboardStats, Error>)
    case strategyGuidesLoaded(Result<[StrategyGuideItem], Error>)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case (.dashboardStatsLoaded(.success(let l)), .dashboardStatsLoaded(.success(let r))): return l == r
      case (.dashboardStatsLoaded(.failure), .dashboardStatsLoaded(.failure)): return true
      case (.strategyGuidesLoaded(.success(let l)), .strategyGuidesLoaded(.success(let r))): return l == r
      case (.strategyGuidesLoaded(.failure), .strategyGuidesLoaded(.failure)): return true
      default: return false
      }
    }
  }

  public init() {}
  
  @Dependency(\.homeRepository) var homeRepository

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.dashboardStats == nil && !state.isLoading else { return .none }
        state.isLoading = true
        return .run { send in
          async let statsResult = Result { try await homeRepository.fetchDashboardStats() }
          async let guidesResult = Result { try await homeRepository.fetchStrategyGuides() }
          await send(.dashboardStatsLoaded(await statsResult))
          await send(.strategyGuidesLoaded(await guidesResult))
        }
        
      case let .dashboardStatsLoaded(.success(stats)):
        state.dashboardStats = stats
        state.isLoading = false
        return .none
        
      case let .dashboardStatsLoaded(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
        
      case let .strategyGuidesLoaded(.success(guides)):
        state.strategyGuides = guides
        return .none
        
      case let .strategyGuidesLoaded(.failure(error)):
        state.error = error.localizedDescription
        return .none
      }
    }
  }
}
