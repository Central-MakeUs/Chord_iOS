import ComposableArchitecture
import CoreModels
import Foundation

@Reducer
public struct MenuEditFeature {
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
        return .none
      case let .menuPriceUpdated(price):
        state.menuPrice = price
        state.isPriceEditPresented = false
        return .none
      case let .prepareTimeUpdated(minutes, seconds):
        state.prepareTime = "\(minutes)분 \(seconds)초"
        state.isPrepareTimePresented = false
        return .none
      case .prepareTimeTapped:
        state.isPrepareTimePresented = true
        return .none
      case let .categorySelected(category):
        state.selectedCategory = category
        return .none
      case .deleteTapped, .backTapped:
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
}
