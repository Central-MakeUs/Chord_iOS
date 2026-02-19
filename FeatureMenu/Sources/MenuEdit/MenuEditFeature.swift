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
    var prepareTimeMinutes: Int
    var prepareTimeSeconds: Int
    let initialWorkTime: Int
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
      let totalWorkTime = item.workTime ?? 90
      prepareTimeMinutes = totalWorkTime / 60
      prepareTimeSeconds = totalWorkTime % 60
      initialWorkTime = totalWorkTime
      if item.category == .all {
        selectedCategory = .beverage
      } else {
        selectedCategory = item.category
      }
    }
    
    public var categories: [MenuCategory] {
      [.beverage, .food, .dessert]
    }
    
    public var prepareTime: String {
      if prepareTimeMinutes > 0 && prepareTimeSeconds > 0 {
        return "\(prepareTimeMinutes)분 \(prepareTimeSeconds)초"
      } else if prepareTimeMinutes > 0 {
        return "\(prepareTimeMinutes)분"
      } else {
        return "\(prepareTimeSeconds)초"
      }
    }

    public var hasPendingChanges: Bool {
      let normalizedName = menuName.trimmingCharacters(in: .whitespacesAndNewlines)
      let originalName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
      let currentPrice = MenuEditFeature.digitsOnly(menuPrice)
      let originalPrice = MenuEditFeature.digitsOnly(MenuEditFeature.formattedPrice(from: item.price))
      let currentWorkTime = prepareTimeMinutes * 60 + prepareTimeSeconds
      let originalCategory = item.category == .all ? MenuCategory.beverage : item.category

      return normalizedName != originalName
        || currentPrice != originalPrice
        || currentWorkTime != initialWorkTime
        || selectedCategory != originalCategory
    }
  }

  public enum Action: Equatable {
    case nameEditPresented(Bool)
    case priceEditPresented(Bool)
    case prepareTimePresented(Bool)
    case menuNameUpdated(String)
    case menuPriceUpdated(String)
    case menuPriceFieldTapped
    case prepareTimeUpdated(minutes: Int, seconds: Int)
    case prepareTimeTapped
    case categorySelected(MenuCategory)
    case completeEditTapped
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
      case (.menuPriceFieldTapped, .menuPriceFieldTapped): return true
      case let (.prepareTimeUpdated(lm, ls), .prepareTimeUpdated(rm, rs)): return lm == rm && ls == rs
      case (.prepareTimeTapped, .prepareTimeTapped): return true
      case let (.categorySelected(l), .categorySelected(r)): return l == r
      case (.completeEditTapped, .completeEditTapped): return true
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
        return .none

      case let .menuPriceUpdated(price):
        let digits = Self.digitsOnly(price)
        state.menuPrice = digits
        state.isPriceEditPresented = false
        return .none

      case .menuPriceFieldTapped:
        state.menuPrice = Self.digitsOnly(state.menuPrice)
        return .none

      case let .prepareTimeUpdated(minutes, seconds):
        state.prepareTimeMinutes = minutes
        state.prepareTimeSeconds = seconds
        state.isPrepareTimePresented = false
        return .none

      case .prepareTimeTapped:
        state.isPrepareTimePresented = true
        return .none

      case let .categorySelected(category):
        state.selectedCategory = category
        return .none

      case .completeEditTapped:
        guard !state.isUpdating else { return .none }
        guard state.hasPendingChanges else { return .none }
        guard let apiId = state.item.apiId else { return .none }

        let normalizedName = state.menuName.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalName = state.item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasNameChanged = normalizedName != originalName && !normalizedName.isEmpty

        let currentPriceDigits = Self.digitsOnly(state.menuPrice)
        let originalPriceDigits = Self.digitsOnly(Self.formattedPrice(from: state.item.price))
        let hasPriceChanged = currentPriceDigits != originalPriceDigits && !currentPriceDigits.isEmpty
        let currentPriceValue = Double(currentPriceDigits)

        let currentWorkTime = state.prepareTimeMinutes * 60 + state.prepareTimeSeconds
        let hasWorkTimeChanged = currentWorkTime != state.initialWorkTime

        let originalCategory = state.item.category == .all ? MenuCategory.beverage : state.item.category
        let hasCategoryChanged = state.selectedCategory != originalCategory

        if hasPriceChanged, currentPriceValue == nil {
          return .none
        }

        state.isUpdating = true
        let selectedCategoryCode = hasCategoryChanged ? categoryToCode(state.selectedCategory) : nil
        return .run { send in
          do {
            if hasNameChanged {
              try await menuRepository.updateMenuName(apiId, MenuNameUpdateRequest(menuName: normalizedName))
            }

            if hasPriceChanged, let currentPriceValue {
              try await menuRepository.updateMenuPrice(apiId, MenuPriceUpdateRequest(sellingPrice: currentPriceValue))
            }

            if let selectedCategoryCode {
              try await menuRepository.updateMenuCategory(apiId, MenuCategoryUpdateRequest(category: selectedCategoryCode))
            }

            if hasWorkTimeChanged {
              try await menuRepository.updateWorkTime(apiId, MenuWorktimeUpdateRequest(workTime: currentWorkTime))
            }

            await send(.updateResponse(.success(())))
          } catch {
            await send(.updateResponse(.failure(error)))
          }
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

  static func digitsOnly(_ value: String) -> String {
    value.filter { $0.isNumber }
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
