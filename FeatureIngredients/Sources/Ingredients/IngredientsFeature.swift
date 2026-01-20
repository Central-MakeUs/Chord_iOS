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
    var menuItems: [MenuItem] = []
    var isLoading = false
    var error: String?
    var isSearchMode = false
    var recentSearches: [String] = ["레몬티", "딸기 가루"]

    public init() {}
    
    public var filteredIngredients: [InventoryIngredientItem] {
      if searchText.isEmpty {
        return ingredients
      }
      return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    public var searchResults: [String] {
      let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return [] }
      
      var results: [String] = []
      for menu in menuItems {
        if menu.name.localizedCaseInsensitiveContains(trimmed) {
          results.append(contentsOf: menu.ingredients.map { $0.name })
        }
      }
      return Array(Set(results)).sorted()
    }
  }

  public enum Action: Equatable {
    case onAppear
    case selectedSearchChanged(String)
    case searchTextChanged(String)
    case pathChanged([IngredientsRoute])
    case searchChipTapped(String)
    case searchButtonTapped
    case cancelSearchTapped
    case removeRecentSearch(String)
    case ingredientsLoaded(Result<[InventoryIngredientItem], Error>)
    case menuItemsLoaded(Result<[MenuItem], Error>)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.selectedSearchChanged(l), .selectedSearchChanged(r)): return l == r
      case let (.searchTextChanged(l), .searchTextChanged(r)): return l == r
      case let (.pathChanged(l), .pathChanged(r)): return l == r
      case let (.searchChipTapped(l), .searchChipTapped(r)): return l == r
      case (.searchButtonTapped, .searchButtonTapped): return true
      case (.cancelSearchTapped, .cancelSearchTapped): return true
      case let (.removeRecentSearch(l), .removeRecentSearch(r)): return l == r
      case (.ingredientsLoaded(.success(let l)), .ingredientsLoaded(.success(let r))): return l == r
      case (.ingredientsLoaded(.failure), .ingredientsLoaded(.failure)): return true
      case (.menuItemsLoaded(.success(let l)), .menuItemsLoaded(.success(let r))): return l == r
      case (.menuItemsLoaded(.failure), .menuItemsLoaded(.failure)): return true
      default: return false
      }
    }
  }

  public init() {}
  
  @Dependency(\.ingredientRepository) var ingredientRepository
  @Dependency(\.menuRepository) var menuRepository

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.ingredients.isEmpty && !state.isLoading else { return .none }
        state.isLoading = true
        return .merge(
          .run { send in
            let result = await Result { try await ingredientRepository.fetchIngredients() }
            await send(.ingredientsLoaded(result))
          },
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuItems() }
            await send(.menuItemsLoaded(result))
          }
        )
        
      case let .ingredientsLoaded(.success(items)):
        state.ingredients = items
        state.isLoading = false
        state.error = nil
        return .none
        
      case let .ingredientsLoaded(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
        
      case let .menuItemsLoaded(.success(items)):
        state.menuItems = items
        return .none
        
      case let .menuItemsLoaded(.failure(error)):
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
        
      case .searchButtonTapped:
        state.isSearchMode = true
        return .none
        
      case .cancelSearchTapped:
        state.isSearchMode = false
        state.searchText = ""
        return .none
        
      case let .removeRecentSearch(keyword):
        state.recentSearches.removeAll { $0 == keyword }
        return .none
      }
    }
  }
}
