import Foundation
import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct MenuIngredientsFeature {
  @Dependency(\.recipeRepository) var recipeRepository
  @Dependency(\.ingredientRepository) var ingredientRepository
  
  public struct State: Equatable {
    let menuId: Int
    let menuName: String
    var ingredients: [IngredientItem]
    var selectedTab: IngredientTab = .ingredient
    var isEditMode: Bool = false
    var selectedIngredients: Set<UUID> = []
    var showAddSheet: Bool = false
    var isLoading: Bool = false
    var isUpdatingIngredient: Bool = false
    var isManageMenuPresented: Bool = false
    var showToast: Bool = false
    var toastMessage: String = ""
    var pendingDeleteCount: Int = 0
    var shouldShowUpdatedToast: Bool = false
    var showIngredientDetailSheet: Bool = false
    var selectedIngredient: IngredientItem?
    var selectedIngredientUsage: String = ""
    var selectedIngredientUnit: IngredientUnit = .g
    var selectedIngredientUnitPriceText: String = "-"
    var selectedIngredientSupplier: String = "-"
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
    case deleteButtonTapped
    case showToastChanged(Bool)
    case selectedTabChanged(IngredientTab)
    case ingredientToggled(UUID)
    case deleteRecipesResponse(Result<Void, Error>)
    case addSheetPresented(Bool)
    case ingredientAdded(IngredientItem)
    case ingredientRowTapped(IngredientItem)
    case ingredientDetailSheetPresented(Bool)
    case ingredientDetailUsageChanged(String)
    case ingredientDetailLoaded(Result<InventoryIngredientItem, Error>)
    case ingredientUpdateTapped
    case ingredientUpdated(Result<Void, Error>)
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
      case (.deleteButtonTapped, .deleteButtonTapped): return true
      case let (.showToastChanged(l), .showToastChanged(r)): return l == r
      case let (.selectedTabChanged(l), .selectedTabChanged(r)): return l == r
      case let (.ingredientToggled(l), .ingredientToggled(r)): return l == r
      case (.deleteRecipesResponse(.success), .deleteRecipesResponse(.success)): return true
      case (.deleteRecipesResponse(.failure), .deleteRecipesResponse(.failure)): return true
      case let (.addSheetPresented(l), .addSheetPresented(r)): return l == r
      case let (.ingredientAdded(l), .ingredientAdded(r)): return l == r
      case let (.ingredientRowTapped(l), .ingredientRowTapped(r)): return l == r
      case let (.ingredientDetailSheetPresented(l), .ingredientDetailSheetPresented(r)): return l == r
      case let (.ingredientDetailUsageChanged(l), .ingredientDetailUsageChanged(r)): return l == r
      case (.ingredientDetailLoaded(.success), .ingredientDetailLoaded(.success)): return true
      case (.ingredientDetailLoaded(.failure), .ingredientDetailLoaded(.failure)): return true
      case (.ingredientUpdateTapped, .ingredientUpdateTapped): return true
      case (.ingredientUpdated(.success), .ingredientUpdated(.success)): return true
      case (.ingredientUpdated(.failure), .ingredientUpdated(.failure)): return true
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
        state.isEditMode.toggle()
        if !state.isEditMode {
          state.selectedIngredients.removeAll()
        }
        return .none

      case .deleteButtonTapped:
        guard state.isEditMode, !state.selectedIngredients.isEmpty else { return .none }

        let selectedCount = state.selectedIngredients.count
        state.pendingDeleteCount = selectedCount

        let recipeIds = state.ingredients
          .filter { state.selectedIngredients.contains($0.id) }
          .compactMap { $0.recipeId }

        guard !recipeIds.isEmpty else {
          state.ingredients.removeAll { state.selectedIngredients.contains($0.id) }
          state.selectedIngredients.removeAll()
          state.isEditMode = false
          state.toastMessage = "\(selectedCount)개의 재료가 삭제됐어요"
          state.showToast = true
          state.pendingDeleteCount = 0
          return .none
        }

        state.isLoading = true
        let menuId = state.menuId
        let request = DeleteRecipesRequest(recipeIds: recipeIds)

        return .run { send in
          let result = await Result { try await recipeRepository.deleteRecipes(menuId, request) }
          await send(.deleteRecipesResponse(result))
        }

      case let .showToastChanged(isPresented):
        state.showToast = isPresented
        if !isPresented {
          state.toastMessage = ""
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

      case let .ingredientRowTapped(ingredient):
        guard !state.isEditMode else { return .none }

        state.selectedIngredient = ingredient
        state.showIngredientDetailSheet = true
        state.selectedIngredientUsage = Self.amountValueText(from: ingredient.amount)
        state.selectedIngredientUnit = Self.unit(from: ingredient.amount)
        state.selectedIngredientUnitPriceText = "\(ingredient.amount)당 \(ingredient.price)"
        state.selectedIngredientSupplier = "-"

        guard let ingredientId = ingredient.ingredientId else { return .none }

        return .run { send in
          let result = await Result { try await ingredientRepository.fetchIngredientDetail(ingredientId) }
          await send(.ingredientDetailLoaded(result))
        }

      case let .ingredientDetailSheetPresented(isPresented):
        state.showIngredientDetailSheet = isPresented
        if !isPresented {
          state.selectedIngredient = nil
          state.selectedIngredientUsage = ""
          state.selectedIngredientUnitPriceText = "-"
          state.selectedIngredientSupplier = "-"
          state.isUpdatingIngredient = false
        }
        return .none

      case let .ingredientDetailUsageChanged(usage):
        state.selectedIngredientUsage = Self.sanitizedDecimalsAndCommas(usage)
        return .none

      case let .ingredientDetailLoaded(.success(detail)):
        state.selectedIngredientUnitPriceText = "\(detail.amount)당 \(detail.price)"
        if let supplier = detail.supplier, !supplier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          state.selectedIngredientSupplier = supplier
        } else {
          state.selectedIngredientSupplier = "-"
        }
        return .none

      case .ingredientDetailLoaded(.failure):
        return .none

      case .ingredientUpdateTapped:
        guard let ingredient = state.selectedIngredient,
              let recipeId = ingredient.recipeId
        else {
          return .none
        }

        let usageText = state.selectedIngredientUsage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !usageText.isEmpty, let amount = Double(usageText.replacingOccurrences(of: ",", with: "")) else {
          state.alert = AlertState { TextState("수정 실패") } message: { TextState("사용량을 확인해주세요") }
          return .none
        }

        state.isUpdatingIngredient = true
        state.isLoading = true

        let menuId = state.menuId
        let request = AmountUpdateRequest(amount: amount)

        return .run { send in
          let result = await Result { try await recipeRepository.updateRecipe(menuId, recipeId, request) }
          await send(.ingredientUpdated(result))
        }

      case .ingredientUpdated(.success):
        state.isUpdatingIngredient = false
        state.showIngredientDetailSheet = false
        state.shouldShowUpdatedToast = true
        return .send(.reloadRecipes)

      case let .ingredientUpdated(.failure(error)):
        state.isLoading = false
        state.isUpdatingIngredient = false
        state.alert = AlertState { TextState("수정 실패") } message: { TextState(errorMessage(from: error)) }
        return .none
        
      case .deleteRecipesResponse(.success):
        let deletedCount = state.pendingDeleteCount
        state.ingredients.removeAll { state.selectedIngredients.contains($0.id) }
        state.selectedIngredients.removeAll()
        state.isEditMode = false
        state.isLoading = false
        state.toastMessage = "\(deletedCount)개의 재료가 삭제됐어요"
        state.showToast = true
        state.pendingDeleteCount = 0
        return .none
        
      case let .deleteRecipesResponse(.failure(error)):
        state.isLoading = false
        state.pendingDeleteCount = 0
        state.alert = AlertState { TextState("삭제 실패") } message: { TextState(errorMessage(from: error)) }
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
            usageAmount: amount,
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
        state.alert = AlertState { TextState("재료 추가 실패") } message: { TextState(errorMessage(from: error)) }
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
            amount: "\(Int(recipe.amount))\(IngredientUnit.from(recipe.unitCode).title)",
            price: Self.formattedPriceText(recipe.price)
          )
        }
        state.isLoading = false
        if state.shouldShowUpdatedToast {
          state.toastMessage = "수정이 반영되었어요"
          state.showToast = true
          state.shouldShowUpdatedToast = false
        }
        return .none
        
      case let .recipesReloaded(.failure(error)):
        state.isLoading = false
        state.alert = AlertState { TextState("재료 목록 새로고침 실패") } message: { TextState(errorMessage(from: error)) }
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

  private static func amountValueText(from amount: String) -> String {
    amount
      .filter { $0.isNumber || $0 == "." || $0 == "," }
      .replacingOccurrences(of: ",", with: "")
  }

  private static func unit(from amount: String) -> IngredientUnit {
    let unitText = amount
      .filter { !$0.isNumber && $0 != "." && $0 != "," }
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return IngredientUnit.from(unitText)
  }

  private static func sanitizedDecimalsAndCommas(_ value: String) -> String {
    let filtered = value.filter { $0.isNumber || $0 == "." || $0 == "," }
    var hasDot = false
    var result = ""

    for character in filtered {
      if character == "." {
        guard !hasDot else { continue }
        hasDot = true
      }
      result.append(character)
    }

    return result
  }

  private func errorMessage(from error: Error) -> String {
    if let apiError = error as? APIError {
      return apiError.message
    }
    return error.localizedDescription
  }

  private static func formattedPriceText(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    return "\(formatted)원"
  }
}
