import Foundation
import ComposableArchitecture
import CoreModels

@Reducer
public struct MenuIngredientsFeature {
  public struct State: Equatable {
    let menuName: String
    var ingredients: [IngredientItem]
    var selectedTab: IngredientTab = .ingredient
    var isEditMode: Bool = false
    var selectedIngredients: Set<UUID> = []
    var showDeleteAlert: Bool = false
    var showAddSheet: Bool = false
    
    public init(menuName: String, ingredients: [IngredientItem]) {
      self.menuName = menuName
      self.ingredients = ingredients
    }
  }
  
  public enum Action: Equatable {
    case backTapped
    case deleteTapped
    case selectedTabChanged(IngredientTab)
    case ingredientToggled(UUID)
    case deleteAlertConfirmed
    case deleteAlertCancelled
    case addSheetPresented(Bool)
    case ingredientAdded(IngredientItem)
  }
  
  public enum IngredientTab: String, CaseIterable, Equatable {
    case sourceSearch = "출처찾기"
    case ingredient = "식재료"
    case operatingIngredient = "운영 재료"
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .backTapped:
        return .none
        
      case .deleteTapped:
        if state.isEditMode && !state.selectedIngredients.isEmpty {
          state.showDeleteAlert = true
        } else {
          state.isEditMode.toggle()
          if !state.isEditMode {
            state.selectedIngredients.removeAll()
          }
        }
        return .none
        
      case let .selectedTabChanged(tab):
        state.selectedTab = tab
        return .none
        
      case let .ingredientToggled(id):
        if state.selectedIngredients.contains(id) {
          state.selectedIngredients.remove(id)
        } else {
          state.selectedIngredients.insert(id)
        }
        return .none
        
      case .deleteAlertConfirmed:
        state.ingredients.removeAll { state.selectedIngredients.contains($0.id) }
        state.selectedIngredients.removeAll()
        state.isEditMode = false
        state.showDeleteAlert = false
        return .none
        
      case .deleteAlertCancelled:
        state.showDeleteAlert = false
        return .none
        
      case let .addSheetPresented(isPresented):
        state.showAddSheet = isPresented
        return .none
        
      case let .ingredientAdded(ingredient):
        state.ingredients.append(ingredient)
        state.showAddSheet = false
        return .none
      }
    }
  }
}
