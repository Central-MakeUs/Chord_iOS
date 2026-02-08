import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct MenuFeature {
  public struct State: Equatable {
    var selectedCategory: MenuCategory = .all
    var isMenuManagePresented = false
    var menuItems: [MenuItem] = []
    var isLoading = false
    var error: String?

    public init(menuItems: [MenuItem] = []) {
      self.menuItems = menuItems
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case selectedCategoryChanged(MenuCategory)
    case isMenuManagePresentedChanged(Bool)
    case menuItemsLoaded(Result<[MenuItem], Error>)
    case navigateTo(MenuRoute)
    case popToRoot
    case addMenuTapped
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.selectedCategoryChanged(l), .selectedCategoryChanged(r)): return l == r
      case let (.isMenuManagePresentedChanged(l), .isMenuManagePresentedChanged(r)): return l == r
      case (.menuItemsLoaded(.success(let l)), .menuItemsLoaded(.success(let r))): return l == r
      case (.menuItemsLoaded(.failure), .menuItemsLoaded(.failure)): return true
      case let (.navigateTo(l), .navigateTo(r)): return l == r
      case (.popToRoot, .popToRoot): return true
      case (.addMenuTapped, .addMenuTapped): return true
      default: return false
      }
    }
  }
  
  public init() {}
  
  @Dependency(\.menuRepository) var menuRepository
  @Dependency(\.menuRouter) var menuRouter

  private enum CancelID { case router }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let routerEffect: Effect<Action> = .run { send in
          for await routerAction in menuRouter.routePublisher.values {
            switch routerAction {
            case let .push(route):
              await send(.navigateTo(route))
            case .pop, .popToRoot:
              await send(.popToRoot)
            }
          }
        }
        .cancellable(id: CancelID.router)
        
        guard state.menuItems.isEmpty && !state.isLoading else { return routerEffect }
        
        state.isLoading = true
        let category = state.selectedCategory.serverCode
        return .merge(
          routerEffect,
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuItems(category) }
            await send(.menuItemsLoaded(result))
          }
        )
        
      case .navigateTo:
        return .none

      case .popToRoot:
        let category = state.selectedCategory.serverCode
        return .run { send in
          let result = await Result { try await menuRepository.fetchMenuItems(category) }
          await send(.menuItemsLoaded(result))
        }

      case let .menuItemsLoaded(.success(items)):
        state.menuItems = items
        state.isLoading = false
        state.error = nil
        return .none
        
      case let .menuItemsLoaded(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
        
      case let .selectedCategoryChanged(category):
        state.selectedCategory = category
        state.isLoading = true
        let serverCode = category.serverCode
        return .run { send in
          let result = await Result { try await menuRepository.fetchMenuItems(serverCode) }
          await send(.menuItemsLoaded(result))
        }
        
      case let .isMenuManagePresentedChanged(isPresented):
        state.isMenuManagePresented = isPresented
        return .none
        
      case .addMenuTapped:
        state.isMenuManagePresented = false
        return .none
      }
    }
  }
}
