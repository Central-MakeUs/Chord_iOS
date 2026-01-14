import ComposableArchitecture

@Reducer
public struct AICoachFeature {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case backTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
    }
  }
}
