import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct IngredientsFeature {
  public struct State: Equatable {
    var selectedSearch: String? = "식재료"
    var path: [IngredientsRoute] = []
    var ingredients: [InventoryIngredientItem] = []
    var menuItems: [MenuItem] = []
    var isLoading = false
    var error: String?

    public init() {}
    
    public var filteredIngredients: [InventoryIngredientItem] {
      guard let category = selectedSearch else { return ingredients }
      
      switch category {
      case "식재료":
        return ingredients.filter { item in
          !isOperationalItem(item.name)
        }
      case "운영 재료":
        return ingredients.filter { item in
          isOperationalItem(item.name)
        }
      case "출처찾기":
        return ingredients
      default:
        return ingredients
      }
    }
    
    private func isOperationalItem(_ name: String) -> Bool {
      let operationalKeywords = ["컵", "빨대", "홀더", "냅킨", "포장"]
      return operationalKeywords.contains { name.contains($0) }
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case selectedSearchChanged(String?)
    case pathChanged([IngredientsRoute])
    case searchChipTapped(String)
    case searchButtonTapped
    case ingredientsLoaded(Result<[InventoryIngredientItem], Error>)
    case menuItemsLoaded(Result<[MenuItem], Error>)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.selectedSearchChanged(l), .selectedSearchChanged(r)): return l == r
      case let (.pathChanged(l), .pathChanged(r)): return l == r
      case let (.searchChipTapped(l), .searchChipTapped(r)): return l == r
      case (.searchButtonTapped, .searchButtonTapped): return true
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
            let result = await Result { try await ingredientRepository.fetchIngredients(nil) }
            await send(.ingredientsLoaded(result))
          },
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuItems(nil) }
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
        
      case let .pathChanged(path):
        state.path = path
        return .none
        
      case let .searchChipTapped(keyword):
        if state.selectedSearch == keyword {
          state.selectedSearch = nil
        } else {
          state.selectedSearch = keyword
        }
        return .none
        
      case .searchButtonTapped:
        state.path.append(.search)
        return .none
      }
    }
  }
}
