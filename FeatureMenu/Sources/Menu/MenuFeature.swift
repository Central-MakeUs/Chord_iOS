import ComposableArchitecture
import CoreModels
import DataLayer

@Reducer
public struct MenuFeature {
  public struct State: Equatable {
    var selectedCategory: MenuCategory = .all
    var isMenuManagePresented = false
    var path: [MenuRoute] = []
    var menuItems: [MenuItem] = []
    var isLoading = false
    var error: String?

    public init(menuItems: [MenuItem] = []) {
      self.menuItems = menuItems
    }
    
    public var filteredMenuItems: [MenuItem] {
      if selectedCategory == .all {
        return menuItems
      }
      return menuItems.filter { $0.category == selectedCategory }
    }
  }

  public enum Action: Equatable {
    case onAppear
    case selectedCategoryChanged(MenuCategory)
    case isMenuManagePresentedChanged(Bool)
    case pathChanged([MenuRoute])
    case menuItemsLoaded(Result<[MenuItem], Error>)
    case navigateTo(MenuRoute)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.selectedCategoryChanged(l), .selectedCategoryChanged(r)): return l == r
      case let (.isMenuManagePresentedChanged(l), .isMenuManagePresentedChanged(r)): return l == r
      case let (.pathChanged(l), .pathChanged(r)): return l == r
      case (.menuItemsLoaded(.success(let l)), .menuItemsLoaded(.success(let r))): return l == r
      case (.menuItemsLoaded(.failure), .menuItemsLoaded(.failure)): return true
      case let (.navigateTo(l), .navigateTo(r)): return l == r
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
          for await route in menuRouter.routePublisher.values {
            await send(.navigateTo(route))
          }
        }
        .cancellable(id: CancelID.router)
        
        guard state.menuItems.isEmpty && !state.isLoading else { return routerEffect }
        
        state.isLoading = true
        return .merge(
          routerEffect,
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuItems() }
            await send(.menuItemsLoaded(result))
          }
        )
        
      case let .navigateTo(route):
        state.path.append(route)
        return .none

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
        return .none
        
      case let .isMenuManagePresentedChanged(isPresented):
        state.isMenuManagePresented = isPresented
        return .none
        
      case let .pathChanged(path):
        state.path = path
        return .none
      }
    }
  }
}
