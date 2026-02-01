import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

@Reducer
public struct MenuEditFeature {
  @Dependency(\.menuRepository) var menuRepository
  public struct State: Equatable {
    let item: MenuItem
    var menuName: String
    var menuPrice: String
    var prepareTime: String
    var selectedCategory: MenuCategory
    var isNameEditPresented = false
    var isPriceEditPresented = false
    var isPrepareTimePresented = false

    public init(item: MenuItem) {
      self.item = item
      menuName = item.name
      menuPrice = MenuEditFeature.formattedPrice(from: item.price)
      prepareTime = "1분 30초"
      selectedCategory = item.category
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
    case backTapped
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
        
        guard let apiId = state.item.apiId else { return .none }
        let request = MenuNameUpdateRequest(menuName: name)
        return .run { send in
          try await menuRepository.updateMenuName(apiId, request)
        }
      case let .menuPriceUpdated(price):
        state.menuPrice = price
        state.isPriceEditPresented = false
        
        guard let apiId = state.item.apiId else { return .none }
        let numericPrice = price.replacingOccurrences(of: ",", with: "")
        guard let priceValue = Double(numericPrice) else { return .none }
        let request = MenuPriceUpdateRequest(sellingPrice: priceValue)
        return .run { send in
          try await menuRepository.updateMenuPrice(apiId, request)
        }
      case let .prepareTimeUpdated(minutes, seconds):
        state.prepareTime = "\(minutes)분 \(seconds)초"
        state.isPrepareTimePresented = false
        
        guard let apiId = state.item.apiId else { return .none }
        let totalSeconds = minutes * 60 + seconds
        let request = MenuWorktimeUpdateRequest(workTime: totalSeconds)
        return .run { send in
          try await menuRepository.updateWorkTime(apiId, request)
        }
      case .prepareTimeTapped:
        state.isPrepareTimePresented = true
        return .none
      case let .categorySelected(category):
        state.selectedCategory = category
        
        guard let apiId = state.item.apiId else { return .none }
        let categoryCode = categoryToCode(category)
        let request = MenuCategoryUpdateRequest(category: categoryCode)
        return .run { send in
          try await menuRepository.updateMenuCategory(apiId, request)
        }
      case .deleteTapped:
        guard let apiId = state.item.apiId else { return .none }
        return .run { send in
          try await menuRepository.deleteMenu(apiId)
        }
      case .backTapped:
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
