import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct IngredientSearchFeature {
  public struct State: Equatable {
    var searchText = ""
    var recentSearches: [String] = ["레몬티", "딸기 가루"]
    var searchResults: [String] = []
    var isSearching = false
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case searchTextChanged(String)
    case recentSearchTapped(String)
    case removeRecentSearch(String)
    case searchResultsLoaded([SearchMyIngredientsResponse])
  }
  
  public init() {}
  
  @Dependency(\.ingredientRepository) var ingredientRepository
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .searchTextChanged(text):
        state.searchText = text
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          state.searchResults = []
          return .none
        }
        
        state.isSearching = true
        return .run { send in
          let results = try await ingredientRepository.searchIngredients(text)
          await send(.searchResultsLoaded(results))
        } catch: { error, send in
          await send(.searchResultsLoaded([]))
        }
        
      case let .recentSearchTapped(keyword):
        state.searchText = keyword
        return .send(.searchTextChanged(keyword))
        
      case let .removeRecentSearch(keyword):
        state.recentSearches.removeAll { $0 == keyword }
        return .none
        
      case let .searchResultsLoaded(results):
        state.isSearching = false
        state.searchResults = results.map { $0.ingredientName }
        return .none
      }
    }
  }
}
