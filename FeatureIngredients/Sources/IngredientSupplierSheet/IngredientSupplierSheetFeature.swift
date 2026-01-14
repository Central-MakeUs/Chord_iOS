import ComposableArchitecture

@Reducer
public struct IngredientSupplierSheetFeature {
  public struct State: Equatable {
    var draftName: String

    public init(draftName: String) {
      self.draftName = draftName
    }
  }

  public enum Action: Equatable {
    case draftNameChanged(String)
    case clearTapped
    case saveTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .draftNameChanged(name):
        state.draftName = name
        return .none
      case .clearTapped:
        state.draftName = ""
        return .none
      case .saveTapped:
        return .none
      }
    }
  }
}
