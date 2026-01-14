import ComposableArchitecture
import CoreModels

@Reducer
public struct MenuDetailFeature {
  public struct State: Equatable {
    let item: MenuItem

    public init(item: MenuItem) {
      self.item = item
    }
  }

  public enum Action: Equatable {
    case manageTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, _ in
      .none
    }
  }
}
