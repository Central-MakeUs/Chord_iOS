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
    case homeDataLoadFinished
    case dashboardStatsLoaded(Result<DashboardStats, Error>)
    case strategyGuidesLoaded(Result<[StrategyGuideItem], Error>)
    case diagnosisBannerTapped
    case strategyGuideTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case openAICoachTab
    }
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case (.homeDataLoadFinished, .homeDataLoadFinished): return true
      case (.dashboardStatsLoaded(.success(let l)), .dashboardStatsLoaded(.success(let r))): return l == r
      case (.dashboardStatsLoaded(.failure), .dashboardStatsLoaded(.failure)): return true
      case (.strategyGuidesLoaded(.success(let l)), .strategyGuidesLoaded(.success(let r))): return l == r
      case (.strategyGuidesLoaded(.failure), .strategyGuidesLoaded(.failure)): return true
      case (.diagnosisBannerTapped, .diagnosisBannerTapped): return true
      case (.strategyGuideTapped, .strategyGuideTapped): return true
      case let (.delegate(l), .delegate(r)): return l == r
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
        guard !state.isLoading else { return .none }
        state.isLoading = true
        state.error = nil
        return .run { send in
          async let statsResult = Result { try await homeRepository.fetchDashboardStats() }
          async let guidesResult = Result { try await homeRepository.fetchStrategyGuides() }
          await send(.dashboardStatsLoaded(await statsResult))
          await send(.strategyGuidesLoaded(await guidesResult))
          await send(.homeDataLoadFinished)
        }

      case .homeDataLoadFinished:
        state.isLoading = false
        return .none
        
      case let .dashboardStatsLoaded(.success(stats)):
        state.dashboardStats = stats
        state.error = nil
        return .none
        
      case let .dashboardStatsLoaded(.failure(error)):
        state.error = errorMessage(error)
        return .none
        
      case let .strategyGuidesLoaded(.success(guides)):
        state.strategyGuides = guides
        return .none
        
      case let .strategyGuidesLoaded(.failure(error)):
        state.error = errorMessage(error)
        return .none

      case .diagnosisBannerTapped,
          .strategyGuideTapped:
        return .send(.delegate(.openAICoachTab))

      case .delegate:
        return .none
      }
    }
  }

  private func errorMessage(_ error: Error) -> String {
    if let apiError = error as? APIError {
      return apiError.message
    }
    return error.localizedDescription
  }
}
