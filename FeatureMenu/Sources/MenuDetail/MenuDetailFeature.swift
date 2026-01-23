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
    case ingredientsTapped
  }

  public init() {}
  
  @Dependency(\.menuRouter) var menuRouter

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .manageTapped:
        menuRouter.push(.edit(state.item))
        return .none
        
      case .ingredientsTapped:
        menuRouter.push(.ingredients(menuName: state.item.name, ingredients: state.item.ingredients))
        return .none
      }
    }
  }
}
