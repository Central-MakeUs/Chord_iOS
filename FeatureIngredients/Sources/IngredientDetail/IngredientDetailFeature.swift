import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

@Reducer
public struct IngredientDetailFeature {
  @Dependency(\.ingredientRepository) var ingredientRepository
  
  public struct State: Equatable {
    var item: InventoryIngredientItem
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
      if let supplier = item.supplier {
        self.supplierName = supplier
      }
    }
  }

  public enum Action: Equatable {
    case onAppear
    case detailResponse(TaskResult<InventoryIngredientItem>)
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
      case .onAppear:
        guard let apiId = state.item.apiId else { return .none }
        return .run { send in
          await send(.detailResponse(TaskResult {
            try await ingredientRepository.fetchIngredientDetail(apiId)
          }))
        }
        
      case let .detailResponse(.success(item)):
        state.item = item
        let priceDigits = item.price.filter { $0.isNumber }
        state.priceText = IngredientDetailFeature.formattedNumber(from: priceDigits)
        let parsed = IngredientDetailFeature.parseAmount(item.amount)
        state.usageText = parsed.value
        state.unit = parsed.unit
        if let supplier = item.supplier {
          state.supplierName = supplier
        }
        return .none
        
      case .detailResponse(.failure):
        return .none
        
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
        
        guard let apiId = state.item.apiId else { return .none }
        let numericPrice = price.replacingOccurrences(of: ",", with: "")
        guard let priceValue = Double(numericPrice),
              let amountValue = Double(usage) else { return .none }
              
        let request = IngredientUpdateRequest(
          category: state.item.category,
          price: priceValue,
          amount: amountValue,
          unitCode: unit.rawValue
        )
        return .run { send in
          try await ingredientRepository.updateIngredient(apiId, request)
        }
        
      case let .supplierCompleted(name):
        state.supplierName = name
        state.isSupplierPresented = false
        
        guard let apiId = state.item.apiId else { return .none }
        let request = SupplierUpdateRequest(supplier: name)
        return .run { send in
          try await ingredientRepository.updateSupplier(apiId, request)
        }
        
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
