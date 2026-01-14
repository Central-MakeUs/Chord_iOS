import ComposableArchitecture
import CoreModels

@Reducer
public struct IngredientEditSheetFeature {
  public struct State: Equatable {
    let name: String
    var draftPrice: String
    var draftUsage: String
    var draftUnit: IngredientUnit
    let initialPrice: String
    let initialUsage: String
    let initialUnit: IngredientUnit

    public init(
      name: String,
      draftPrice: String,
      draftUsage: String,
      draftUnit: IngredientUnit,
      initialPrice: String,
      initialUsage: String,
      initialUnit: IngredientUnit
    ) {
      self.name = name
      self.draftPrice = draftPrice
      self.draftUsage = draftUsage
      self.draftUnit = draftUnit
      self.initialPrice = initialPrice
      self.initialUsage = initialUsage
      self.initialUnit = initialUnit
    }
  }

  public enum Action: Equatable {
    case draftPriceChanged(String)
    case draftUsageChanged(String)
    case unitSelected(IngredientUnit)
    case saveTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .draftPriceChanged(price):
        state.draftPrice = price
        return .none
      case let .draftUsageChanged(usage):
        state.draftUsage = usage
        return .none
      case let .unitSelected(unit):
        state.draftUnit = unit
        return .none
      case .saveTapped:
        return .none
      }
    }
  }
}
