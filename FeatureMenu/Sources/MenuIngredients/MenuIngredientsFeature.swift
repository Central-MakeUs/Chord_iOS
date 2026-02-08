import Foundation
import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct MenuIngredientsFeature {
  @Dependency(\.recipeRepository) var recipeRepository
  
  public struct State: Equatable {
    let menuId: Int
    let menuName: String
    var ingredients: [IngredientItem]
    var selectedTab: IngredientTab = .ingredient
    var isEditMode: Bool = false
    var selectedIngredients: Set<UUID> = []
    var showDeleteAlert: Bool = false
    var showAddSheet: Bool = false
    var isLoading: Bool = false
    var isManageMenuPresented: Bool = false
    @PresentationState var alert: AlertState<Action.Alert>?
    
    public init(menuId: Int, menuName: String, ingredients: [IngredientItem]) {
      self.menuId = menuId
      self.menuName = menuName
      self.ingredients = ingredients
    }
  }
  
  public enum Action: Equatable {
    case backTapped
    case manageTapped
    case manageMenuDismissed
    case addTapped
    case deleteTapped
    case selectedTabChanged(IngredientTab)
    case ingredientToggled(UUID)
    case deleteAlertConfirmed
    case deleteAlertCancelled
    case deleteRecipesResponse(Result<Void, Error>)
    case addSheetPresented(Bool)
    case ingredientAdded(IngredientItem)
    case addRecipeResponse(Result<Void, Error>)
    case reloadRecipes
    case recipesReloaded(Result<RecipeListResponse, Error>)
    case alert(PresentationAction<Alert>)
    
    public enum Alert: Equatable {}
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.backTapped, .backTapped): return true
      case (.manageTapped, .manageTapped): return true
      case (.manageMenuDismissed, .manageMenuDismissed): return true
      case (.addTapped, .addTapped): return true
      case (.deleteTapped, .deleteTapped): return true
      case let (.selectedTabChanged(l), .selectedTabChanged(r)): return l == r
      case let (.ingredientToggled(l), .ingredientToggled(r)): return l == r
      case (.deleteAlertConfirmed, .deleteAlertConfirmed): return true
      case (.deleteAlertCancelled, .deleteAlertCancelled): return true
      case (.deleteRecipesResponse(.success), .deleteRecipesResponse(.success)): return true
      case (.deleteRecipesResponse(.failure), .deleteRecipesResponse(.failure)): return true
      case let (.addSheetPresented(l), .addSheetPresented(r)): return l == r
      case let (.ingredientAdded(l), .ingredientAdded(r)): return l == r
      case (.addRecipeResponse(.success), .addRecipeResponse(.success)): return true
      case (.addRecipeResponse(.failure), .addRecipeResponse(.failure)): return true
      case (.reloadRecipes, .reloadRecipes): return true
      case (.recipesReloaded(.success), .recipesReloaded(.success)): return true
      case (.recipesReloaded(.failure), .recipesReloaded(.failure)): return true
      case (.alert, .alert): return true
      default: return false
      }
    }
  }
  
  public enum IngredientTab: String, CaseIterable, Equatable {
    case sourceSearch = "즐겨찾기"
    case ingredient = "식재료"
    case operatingIngredient = "운영 재료"
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .backTapped:
        return .none
        
      case .manageTapped:
        state.isManageMenuPresented = true
        return .none
        
      case .manageMenuDismissed:
        state.isManageMenuPresented = false
        return .none
        
      case .addTapped:
        state.isManageMenuPresented = false
        state.showAddSheet = true
        return .none
        
      case .deleteTapped:
        state.isManageMenuPresented = false
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
        let recipeIds = state.ingredients
          .filter { state.selectedIngredients.contains($0.id) }
          .compactMap { $0.recipeId }
        
        guard !recipeIds.isEmpty else {
          state.ingredients.removeAll { state.selectedIngredients.contains($0.id) }
          state.selectedIngredients.removeAll()
          state.isEditMode = false
          state.showDeleteAlert = false
          return .none
        }
        
        state.isLoading = true
        state.showDeleteAlert = false
        let menuId = state.menuId
        let request = DeleteRecipesRequest(recipeIds: recipeIds)
        let ingredientsToDelete = state.selectedIngredients
        
        return .run { send in
          let result = await Result { try await recipeRepository.deleteRecipes(menuId, request) }
          await send(.deleteRecipesResponse(result))
        }
        
      case .deleteRecipesResponse(.success):
        state.ingredients.removeAll { state.selectedIngredients.contains($0.id) }
        state.selectedIngredients.removeAll()
        state.isEditMode = false
        state.isLoading = false
        return .none
        
      case let .deleteRecipesResponse(.failure(error)):
        state.isLoading = false
        state.alert = AlertState { TextState("삭제 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case .deleteAlertCancelled:
        state.showDeleteAlert = false
        return .none
        
      case let .addSheetPresented(isPresented):
        state.showAddSheet = isPresented
        return .none
        
      case let .ingredientAdded(ingredient):
        state.isLoading = true
        state.showAddSheet = false
        let menuId = state.menuId
        
        if let ingredientId = ingredient.ingredientId {
          let amountString = ingredient.amount.filter { $0.isNumber || $0 == "." }
          let amount = Double(amountString) ?? 0
          let request = RecipeCreateRequest(ingredientId: ingredientId, amount: amount)
          return .run { send in
            let result = await Result { try await recipeRepository.createRecipeWithExisting(menuId, request) }
            await send(.addRecipeResponse(result))
          }
        } else {
          let amountString = ingredient.amount.filter { $0.isNumber || $0 == "." }
          let amount = Double(amountString) ?? 0
          let priceString = ingredient.price.filter { $0.isNumber || $0 == "." }
          let price = Double(priceString) ?? 0
          let unitCode = extractUnitCode(from: ingredient.amount)
          
          let request = NewRecipeCreateRequest(
            amount: amount,
            price: price,
            unitCode: unitCode,
            ingredientCategoryCode: "INGREDIENTS",
            ingredientName: ingredient.name
          )
          return .run { send in
            let result = await Result { try await recipeRepository.createRecipeWithNew(menuId, request) }
            await send(.addRecipeResponse(result))
          }
        }
        
      case .addRecipeResponse(.success):
        return .send(.reloadRecipes)
        
      case let .addRecipeResponse(.failure(error)):
        state.isLoading = false
        state.alert = AlertState { TextState("재료 추가 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case .reloadRecipes:
        let menuId = state.menuId
        return .run { send in
          let result = await Result { try await recipeRepository.fetchRecipes(menuId) }
          await send(.recipesReloaded(result))
        }
        
      case let .recipesReloaded(.success(response)):
        state.ingredients = response.recipes.map { recipe in
          IngredientItem(
            id: UUID(),
            recipeId: recipe.recipeId,
            ingredientId: recipe.ingredientId,
            name: recipe.ingredientName,
            amount: "\(Int(recipe.amount))\(recipe.unitCode)",
            price: "\(Int(recipe.price))원"
          )
        }
        state.isLoading = false
        return .none
        
      case let .recipesReloaded(.failure(error)):
        state.isLoading = false
        state.alert = AlertState { TextState("재료 목록 새로고침 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
  }
  
  private func extractUnitCode(from amount: String) -> String {
    let unitText = amount.filter { !$0.isNumber && $0 != "." }
    switch unitText.lowercased() {
    case "g": return "G"
    case "ml": return "ML"
    case "ea", "개": return "EA"
    default: return "G"
    }
  }
}
