import ComposableArchitecture

@Reducer
public struct MenuPriceEditSheetFeature {
  public struct State: Equatable {
    var draftPrice: String

    public init(draftPrice: String) {
      self.draftPrice = draftPrice
    }
  }

  public enum Action: Equatable {
    case draftPriceChanged(String)
    case clearTapped
    case saveTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .draftPriceChanged(value):
        state.draftPrice = value
        return .none
      case .clearTapped:
        state.draftPrice = ""
        return .none
      case .saveTapped:
        return .none
      }
    }
  }
}
