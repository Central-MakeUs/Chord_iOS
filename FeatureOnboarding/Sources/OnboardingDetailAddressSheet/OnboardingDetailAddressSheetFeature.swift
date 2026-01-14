import ComposableArchitecture

@Reducer
public struct OnboardingDetailAddressSheetFeature {
  public struct State: Equatable {
    var draftAddress: String

    public init(draftAddress: String) {
      self.draftAddress = draftAddress
    }
  }

  public enum Action: Equatable {
    case draftAddressChanged(String)
    case saveTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .draftAddressChanged(address):
        state.draftAddress = address
        return .none
      case .saveTapped:
        return .none
      }
    }
  }
}
