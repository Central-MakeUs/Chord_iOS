import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct IngredientsFeature {
  public struct State: Equatable {
    var selectedSearch = "식재료"
    var searchText = ""
    var path: [IngredientsRoute] = []
    var ingredients: [InventoryIngredientItem] = []
    var isLoading = false
    var error: String?

    public init() {}
    
    public var filteredIngredients: [InventoryIngredientItem] {
      if searchText.isEmpty {
        return ingredients
      }
      return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
  }

  public enum Action: Equatable {
    case onAppear
    case selectedSearchChanged(String)
    case searchTextChanged(String)
    case pathChanged([IngredientsRoute])
    case searchChipTapped(String)
    case ingredientsLoaded(Result<[InventoryIngredientItem], Error>)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.selectedSearchChanged(l), .selectedSearchChanged(r)): return l == r
      case let (.searchTextChanged(l), .searchTextChanged(r)): return l == r
      case let (.pathChanged(l), .pathChanged(r)): return l == r
      case let (.searchChipTapped(l), .searchChipTapped(r)): return l == r
      case (.ingredientsLoaded(.success(let l)), .ingredientsLoaded(.success(let r))): return l == r
      case (.ingredientsLoaded(.failure), .ingredientsLoaded(.failure)): return true
      default: return false
      }
    }
  }

  public init() {}
  
  @Dependency(\.ingredientRepository) var ingredientRepository

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.ingredients.isEmpty && !state.isLoading else { return .none }
        state.isLoading = true
        return .run { send in
          let result = await Result { try await ingredientRepository.fetchIngredients() }
          await send(.ingredientsLoaded(result))
        }
        
      case let .ingredientsLoaded(.success(items)):
        state.ingredients = items
        state.isLoading = false
        state.error = nil
        return .none
        
      case let .ingredientsLoaded(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
        
      case let .selectedSearchChanged(selected):
        state.selectedSearch = selected
        return .none
        
      case let .searchTextChanged(text):
        state.searchText = text
        return .none
        
      case let .pathChanged(path):
        state.path = path
        return .none
        
      case let .searchChipTapped(keyword):
        state.selectedSearch = keyword
        return .none
      }
    }
  }
}
