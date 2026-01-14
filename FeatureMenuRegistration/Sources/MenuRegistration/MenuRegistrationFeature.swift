import ComposableArchitecture

@Reducer
public struct MenuRegistrationFeature {
  public enum Category: String, CaseIterable, Hashable {
    case beverage = "음료"
    case dessert = "디저트"
  }

  public struct State: Equatable {
    var menuName = ""
    var price = ""
    var selectedCategory: Category = .beverage
    var ingredients: [String] = ["원두"]

    public init() {}
  }

  public enum Action: Equatable {
    case menuNameChanged(String)
    case priceChanged(String)
    case categorySelected(Category)
    case addIngredientTapped
    case backTapped
    case completeTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .menuNameChanged(name):
        state.menuName = name
        return .none

      case let .priceChanged(price):
        state.price = price
        return .none

      case let .categorySelected(category):
        state.selectedCategory = category
        return .none

      case .addIngredientTapped:
        return .none

      case .backTapped,
           .completeTapped:
        return .none
      }
    }
  }
}
