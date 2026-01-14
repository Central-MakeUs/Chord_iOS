import ComposableArchitecture
import CoreModels
import Foundation

@Reducer
public struct IngredientDetailFeature {
  public struct State: Equatable {
    let item: InventoryIngredientItem
    var priceText: String
    var usageText: String
    var unit: IngredientUnit
    var supplierName: String = "쿠팡"
    var isEditPresented = false
    var isSupplierPresented = false

    public init(item: InventoryIngredientItem) {
      self.item = item
      let priceDigits = item.price.filter { $0.isNumber }
      let formattedPrice = IngredientDetailFeature.formattedNumber(from: priceDigits)
      let parsed = IngredientDetailFeature.parseAmount(item.amount)
      priceText = formattedPrice
      usageText = parsed.value
      unit = parsed.unit
    }
  }

  public enum Action: Equatable {
    case editPresented(Bool)
    case supplierPresented(Bool)
    case editCompleted(price: String, usage: String, unit: IngredientUnit)
    case supplierCompleted(String)
    case backTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .editPresented(isPresented):
        state.isEditPresented = isPresented
        return .none
      case let .supplierPresented(isPresented):
        state.isSupplierPresented = isPresented
        return .none
      case let .editCompleted(price, usage, unit):
        state.priceText = price
        state.usageText = usage
        state.unit = unit
        state.isEditPresented = false
        return .none
      case let .supplierCompleted(name):
        state.supplierName = name
        state.isSupplierPresented = false
        return .none
      case .backTapped:
        return .none
      }
    }
  }
}

private extension IngredientDetailFeature {
  static func formattedNumber(from value: String) -> String {
    guard let number = Int64(value) else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? value
  }

  static func parseAmount(_ value: String) -> (value: String, unit: IngredientUnit) {
    let digits = value.filter { $0.isNumber }
    let unitText = value.filter { !$0.isNumber }
    let unit = IngredientUnit.from(unitText)
    return (digits.isEmpty ? value : digits, unit)
  }
}
