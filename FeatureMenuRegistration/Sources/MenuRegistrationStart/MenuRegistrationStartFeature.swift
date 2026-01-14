import ComposableArchitecture

@Reducer
public struct MenuRegistrationStartFeature {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case startTapped
    case skipTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
    }
  }
}
