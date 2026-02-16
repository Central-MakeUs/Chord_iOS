import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

private enum RecentSearchStorage {
  static let key = "recentIngredientSearches"
  static let maxCount = 10
  
  static func load() -> [String] {
    UserDefaults.standard.stringArray(forKey: key) ?? []
  }
  
  static func save(_ searches: [String]) {
    let trimmed = Array(searches.prefix(maxCount))
    UserDefaults.standard.set(trimmed, forKey: key)
  }
}

@Reducer
public struct IngredientSearchFeature {
  public struct State: Equatable {
    var searchText = ""
    var recentSearches: [String] = RecentSearchStorage.load()
    var searchResults: [SearchMyIngredientsResponse] = []
    var isSearching = false
    @PresentationState var detail: IngredientDetailFeature.State?
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case searchTextChanged(String)
    case recentSearchTapped(String)
    case removeRecentSearch(String)
    case searchResultTapped(SearchMyIngredientsResponse)
    case searchResultsLoaded([SearchMyIngredientsResponse])
    case detail(PresentationAction<IngredientDetailFeature.Action>)
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
          let results = try await ingredientRepository.searchIngredientsInCatalog(text)
          await send(.searchResultsLoaded(results))
        } catch: { error, send in
          await send(.searchResultsLoaded([]))
        }
        
      case let .recentSearchTapped(keyword):
        state.searchText = keyword
        return .send(.searchTextChanged(keyword))
        
      case let .removeRecentSearch(keyword):
        state.recentSearches.removeAll { $0 == keyword }
        RecentSearchStorage.save(state.recentSearches)
        return .none
      
      case let .searchResultTapped(result):
        state.recentSearches.removeAll { $0 == result.ingredientName }
        state.recentSearches.insert(result.ingredientName, at: 0)
        RecentSearchStorage.save(state.recentSearches)
        
        let item = InventoryIngredientItem(
          apiId: result.ingredientId,
          name: result.ingredientName,
          amount: "",
          price: ""
        )
        state.detail = IngredientDetailFeature.State(item: item)
        return .none
        
      case let .searchResultsLoaded(results):
        state.isSearching = false
        state.searchResults = results
        return .none
        
      case .detail:
        return .none
      }
    }
    .ifLet(\.$detail, action: \.detail) {
      IngredientDetailFeature()
    }
  }
}
