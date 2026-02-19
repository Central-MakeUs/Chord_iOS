import ComposableArchitecture
import Foundation
import CoreModels
import DataLayer

@Reducer
public struct MenuDetailFeature {
  @Dependency(\.menuRepository) var menuRepository
  @Dependency(\.recipeRepository) var recipeRepository
  @Dependency(\.menuRouter) var menuRouter

  public struct State: Equatable {
    var item: MenuItem
    var isLoading = false
    var isManageMenuPresented = false
    var isDeleteConfirmPresented = false
    var isDeleteSuccessPresented = false
    var isDeleting = false
    @PresentationState var alert: AlertState<Action.Alert>?

    public init(item: MenuItem) {
      self.item = item
    }
  }

  public enum Action: Equatable {
    case onAppear
    case menuDetailLoaded(Result<MenuItem, Error>)
    case recipesLoaded(Result<RecipeListResponse, Error>)
    case manageTapped
    case manageMenuDismissed
    case editTapped
    case deleteTapped
    case deleteConfirmTapped
    case deleteCancelTapped
    case deleteSuccessTapped
    case deleteMenuResponse(Result<Void, Error>)
    case ingredientsTapped
    case backTapped
    case alert(PresentationAction<Alert>)
    
    public enum Alert: Equatable {}
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case (.menuDetailLoaded(.success(let l)), .menuDetailLoaded(.success(let r))): return l == r
      case (.menuDetailLoaded(.failure), .menuDetailLoaded(.failure)): return true
      case (.recipesLoaded(.success(let l)), .recipesLoaded(.success(let r))): return l == r
      case (.recipesLoaded(.failure), .recipesLoaded(.failure)): return true
      case (.manageTapped, .manageTapped): return true
      case (.manageMenuDismissed, .manageMenuDismissed): return true
      case (.editTapped, .editTapped): return true
      case (.deleteTapped, .deleteTapped): return true
      case (.deleteConfirmTapped, .deleteConfirmTapped): return true
      case (.deleteCancelTapped, .deleteCancelTapped): return true
      case (.deleteSuccessTapped, .deleteSuccessTapped): return true
      case (.deleteMenuResponse(.success), .deleteMenuResponse(.success)): return true
      case (.deleteMenuResponse(.failure), .deleteMenuResponse(.failure)): return true
      case (.ingredientsTapped, .ingredientsTapped): return true
      case (.backTapped, .backTapped): return true
      case (.alert(let l), .alert(let r)): return l == r
      default: return false
      }
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        guard let apiId = state.item.apiId else {
          print("❌ MenuDetailFeature.onAppear: apiId is nil")
          return .none
        }
        print("🚀 Fetching Menu Detail & Recipes for ID: \(apiId)")
        return .merge(
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuDetail(apiId) }
            await send(.menuDetailLoaded(result))
          },
          .run { send in
            let result = await Result { try await recipeRepository.fetchRecipes(apiId) }
            await send(.recipesLoaded(result))
          }
        )
        
      case let .menuDetailLoaded(.success(detailItem)):
        print("✅ Menu Detail Loaded: \(detailItem.name)")
        var newItem = detailItem
        newItem = MenuItem(
          id: state.item.id,
          apiId: newItem.apiId,
          name: newItem.name,
          price: newItem.price,
          category: newItem.category,
          status: newItem.status,
          costRate: newItem.costRate,
          marginRate: newItem.marginRate,
          costAmount: newItem.costAmount,
          contribution: newItem.contribution,
          ingredients: state.item.ingredients,
          totalIngredientCost: newItem.totalIngredientCost,
          recommendedPrice: newItem.recommendedPrice,
          workTime: newItem.workTime
        )
        state.item = newItem
        return .none
        
      case .menuDetailLoaded(.failure(let error)):
        print("❌ Menu Detail Failed: \(error)")
        state.isLoading = false
        state.alert = AlertState { TextState("메뉴 상세 정보 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .recipesLoaded(.success(response)):
        print("✅ Recipes Loaded: \(response.recipes.count) items")
        let ingredients = response.recipes.map { recipe in
          IngredientItem(
            id: UUID(),
            recipeId: recipe.recipeId,
            ingredientId: recipe.ingredientId,
            name: recipe.ingredientName,
            amount: "\(Int(recipe.amount))\(IngredientUnit.from(recipe.unitCode).title)",
            price: formattedPriceText(recipe.price)
          )
        }
        
        let newItem = MenuItem(
          id: state.item.id,
          apiId: state.item.apiId,
          name: state.item.name,
          price: state.item.price,
          category: state.item.category,
          status: state.item.status,
          costRate: state.item.costRate,
          marginRate: state.item.marginRate,
          costAmount: state.item.costAmount,
          contribution: state.item.contribution,
          ingredients: ingredients,
          totalIngredientCost: state.item.totalIngredientCost,
          recommendedPrice: state.item.recommendedPrice,
          workTime: state.item.workTime
        )
        state.item = newItem
        state.isLoading = false
        return .none
        
      case .recipesLoaded(.failure(let error)):
        print("❌ Recipes Failed: \(error)")
        state.isLoading = false
        state.alert = AlertState { TextState("레시피 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none

      case .manageTapped:
        state.isManageMenuPresented = true
        return .none

      case .manageMenuDismissed:
        state.isManageMenuPresented = false
        return .none

      case .editTapped:
        guard !state.isLoading else { return .none }
        state.isManageMenuPresented = false
        menuRouter.push(.edit(state.item))
        return .none

      case .deleteTapped:
        state.isManageMenuPresented = false
        state.isDeleteConfirmPresented = true
        return .none

      case .deleteCancelTapped:
        state.isDeleteConfirmPresented = false
        return .none

      case .deleteConfirmTapped:
        guard let apiId = state.item.apiId else { return .none }
        state.isDeleteConfirmPresented = false
        state.isDeleting = true
        return .run { send in
          let result = await Result { try await menuRepository.deleteMenu(apiId) }
          await send(.deleteMenuResponse(result))
        }

      case .deleteMenuResponse(.success):
        state.isDeleting = false
        state.isDeleteSuccessPresented = true
        return .none

      case let .deleteMenuResponse(.failure(error)):
        state.isDeleting = false
        state.alert = AlertState {
          TextState("메뉴 삭제 실패")
        } message: {
          TextState(errorMessage(from: error))
        }
        return .none

      case .deleteSuccessTapped:
        state.isDeleteSuccessPresented = false
        menuRouter.pop()
        return .none
        
      case .ingredientsTapped:
        guard let menuId = state.item.apiId else { return .none }
        menuRouter.push(.ingredients(menuId: menuId, menuName: state.item.name, ingredients: state.item.ingredients))
        return .none
        
      case .backTapped:
        menuRouter.pop()
        return .none
        
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
  }

  private func formattedPriceText(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    return "\(formatted)원"
  }

  private func errorMessage(from error: Error) -> String {
    if let apiError = error as? APIError {
      return apiError.message
    }
    return error.localizedDescription
  }
}
