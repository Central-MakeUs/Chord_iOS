import ComposableArchitecture

@Reducer
public struct OnboardingStaffCountSheetFeature {
  public struct State: Equatable {
    var staffCount: Int

    public init(staffCount: Int) {
      self.staffCount = staffCount
    }
  }

  public enum Action: Equatable {
    case decrementTapped
    case incrementTapped
    case completeTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .decrementTapped:
        state.staffCount = max(1, state.staffCount - 1)
        return .none
      case .incrementTapped:
        state.staffCount += 1
        return .none
      case .completeTapped:
        return .none
      }
    }
  }
}
