import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

@Reducer
public struct MenuEditFeature {
  @Dependency(\.menuRepository) var menuRepository
  @Dependency(\.menuRouter) var menuRouter
  public struct State: Equatable {
    let item: MenuItem
    var menuName: String
    var menuPrice: String
    var prepareTime: String
    var selectedCategory: MenuCategory
    var isNameEditPresented = false
    var isPriceEditPresented = false
    var isPrepareTimePresented = false
    var isDeleteConfirmPresented = false
    var isDeleteSuccessPresented = false
    var isUpdateSuccessPresented = false
    var isUpdating = false

    public init(item: MenuItem) {
      self.item = item
      menuName = item.name
      menuPrice = MenuEditFeature.formattedPrice(from: item.price)
      prepareTime = item.workTimeText
      if item.category == .all {
        selectedCategory = .beverage
      } else {
        selectedCategory = item.category
      }
    }
    
    public var categories: [MenuCategory] {
      [.beverage, .food, .dessert]
    }
    
    public var prepareTimeMinutes: Int {
      let components = prepareTime.components(separatedBy: "분")
      guard let firstPart = components.first,
            let minutes = Int(firstPart.trimmingCharacters(in: .whitespaces)) else {
        return 1
      }
      return minutes
    }
    
    public var prepareTimeSeconds: Int {
      let components = prepareTime.components(separatedBy: "분")
      guard components.count > 1 else { return 30 }
      let secondPart = components[1].replacingOccurrences(of: "초", with: "")
      guard let seconds = Int(secondPart.trimmingCharacters(in: .whitespaces)) else {
        return 30
      }
      return seconds
    }
  }

  public enum Action: Equatable {
    case nameEditPresented(Bool)
    case priceEditPresented(Bool)
    case prepareTimePresented(Bool)
    case menuNameUpdated(String)
    case menuPriceUpdated(String)
    case prepareTimeUpdated(minutes: Int, seconds: Int)
    case prepareTimeTapped
    case categorySelected(MenuCategory)
    case deleteTapped
    case deleteConfirmTapped
    case deleteCancelTapped
    case deleteSuccessTapped
    case deleteMenuResponse(Result<Void, Error>)
    case updateResponse(Result<Void, Error>)
    case updateSuccessDismissed
    case backTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case menuDeleted
    }
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case let (.nameEditPresented(l), .nameEditPresented(r)): return l == r
      case let (.priceEditPresented(l), .priceEditPresented(r)): return l == r
      case let (.prepareTimePresented(l), .prepareTimePresented(r)): return l == r
      case let (.menuNameUpdated(l), .menuNameUpdated(r)): return l == r
      case let (.menuPriceUpdated(l), .menuPriceUpdated(r)): return l == r
      case let (.prepareTimeUpdated(lm, ls), .prepareTimeUpdated(rm, rs)): return lm == rm && ls == rs
      case (.prepareTimeTapped, .prepareTimeTapped): return true
      case let (.categorySelected(l), .categorySelected(r)): return l == r
      case (.deleteTapped, .deleteTapped): return true
      case (.deleteConfirmTapped, .deleteConfirmTapped): return true
      case (.deleteCancelTapped, .deleteCancelTapped): return true
      case (.deleteSuccessTapped, .deleteSuccessTapped): return true
      case (.deleteMenuResponse(.success), .deleteMenuResponse(.success)): return true
      case (.deleteMenuResponse(.failure), .deleteMenuResponse(.failure)): return true
      case (.updateResponse(.success), .updateResponse(.success)): return true
      case (.updateResponse(.failure), .updateResponse(.failure)): return true
      case (.updateSuccessDismissed, .updateSuccessDismissed): return true
      case (.backTapped, .backTapped): return true
      case let (.delegate(l), .delegate(r)): return l == r
      default: return false
      }
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .nameEditPresented(isPresented):
        state.isNameEditPresented = isPresented
        return .none
      case let .priceEditPresented(isPresented):
        state.isPriceEditPresented = isPresented
        return .none
      case let .prepareTimePresented(isPresented):
        state.isPrepareTimePresented = isPresented
        return .none
      case let .menuNameUpdated(name):
        state.menuName = name
        state.isNameEditPresented = false
        
        guard name != state.item.name else { return .none }
        guard let apiId = state.item.apiId else { return .none }
        
        state.isUpdating = true
        let request = MenuNameUpdateRequest(menuName: name)
        return .run { send in
          let result = await Result { try await menuRepository.updateMenuName(apiId, request) }
          await send(.updateResponse(result))
        }
      case let .menuPriceUpdated(price):
        state.menuPrice = price
        state.isPriceEditPresented = false
        
        let originalPrice = Self.formattedPrice(from: state.item.price)
        guard price != originalPrice else { return .none }
        guard let apiId = state.item.apiId else { return .none }
        
        let numericPrice = price.replacingOccurrences(of: ",", with: "")
        guard let priceValue = Double(numericPrice) else { return .none }
        
        state.isUpdating = true
        let request = MenuPriceUpdateRequest(sellingPrice: priceValue)
        return .run { send in
          let result = await Result { try await menuRepository.updateMenuPrice(apiId, request) }
          await send(.updateResponse(result))
        }
      case let .prepareTimeUpdated(minutes, seconds):
        let newPrepareTime = "\(minutes)분 \(seconds)초"
        state.prepareTime = newPrepareTime
        state.isPrepareTimePresented = false
        
        let totalSeconds = minutes * 60 + seconds
        guard totalSeconds != state.item.workTime else { return .none }
        guard let apiId = state.item.apiId else { return .none }
        
        state.isUpdating = true
        let request = MenuWorktimeUpdateRequest(workTime: totalSeconds)
        return .run { send in
          let result = await Result { try await menuRepository.updateWorkTime(apiId, request) }
          await send(.updateResponse(result))
        }
      case .prepareTimeTapped:
        state.isPrepareTimePresented = true
        return .none
      case let .categorySelected(category):
        guard category != state.item.category else {
          state.selectedCategory = category
          return .none
        }
        
        state.selectedCategory = category
        state.isUpdating = true
        
        guard let apiId = state.item.apiId else { return .none }
        let categoryCode = categoryToCode(category)
        let request = MenuCategoryUpdateRequest(category: categoryCode)
        return .run { send in
          let result = await Result { try await menuRepository.updateMenuCategory(apiId, request) }
          await send(.updateResponse(result))
        }
      case .updateResponse(.success):
        state.isUpdating = false
        state.isUpdateSuccessPresented = true
        return .none
        
      case .updateResponse(.failure):
        state.isUpdating = false
        return .none
        
      case .updateSuccessDismissed:
        state.isUpdateSuccessPresented = false
        return .none
      case .deleteTapped:
        state.isDeleteConfirmPresented = true
        return .none
        
      case .deleteConfirmTapped:
        guard let apiId = state.item.apiId else { return .none }
        state.isDeleteConfirmPresented = false
        return .run { send in
          let result = await Result { try await menuRepository.deleteMenu(apiId) }
          await send(.deleteMenuResponse(result))
        }
        
      case .deleteCancelTapped:
        state.isDeleteConfirmPresented = false
        return .none
        
      case .deleteMenuResponse(.success):
        state.isDeleteSuccessPresented = true
        return .none
        
      case .deleteMenuResponse(.failure):
        return .none
        
      case .deleteSuccessTapped:
        state.isDeleteSuccessPresented = false
        menuRouter.popToRoot()
        return .send(.delegate(.menuDeleted))
        
      case .backTapped:
        menuRouter.pop()
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}

private extension MenuEditFeature {
  static func formattedPrice(from value: String) -> String {
    let digits = value.filter { $0.isNumber }
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
  }
  
  func categoryToCode(_ category: MenuCategory) -> String {
    switch category {
    case .all: return "ALL"
    case .beverage: return "BEVERAGE"
    case .food: return "FOOD"
    case .dessert: return "DESSERT"
    }
  }
}
