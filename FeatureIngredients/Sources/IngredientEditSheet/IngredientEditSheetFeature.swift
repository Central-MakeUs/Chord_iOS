import ComposableArchitecture
import CoreModels

@Reducer
public struct IngredientEditSheetFeature {
  public struct State: Equatable {
    let name: String
    var draftCategory: String
    var draftPrice: String
    var draftUsage: String
    var draftUnit: IngredientUnit
    let initialCategory: String
    let initialPrice: String
    let initialUsage: String
    let initialUnit: IngredientUnit

    public init(
      name: String,
      draftCategory: String,
      draftPrice: String,
      draftUsage: String,
      draftUnit: IngredientUnit,
      initialCategory: String,
      initialPrice: String,
      initialUsage: String,
      initialUnit: IngredientUnit
    ) {
      self.name = name
      self.draftCategory = draftCategory
      self.draftPrice = draftPrice
      self.draftUsage = draftUsage
      self.draftUnit = draftUnit
      self.initialCategory = initialCategory
      self.initialPrice = initialPrice
      self.initialUsage = initialUsage
      self.initialUnit = initialUnit
    }
    
    public var cleanedPrice: String {
      draftPrice.replacingOccurrences(of: ",", with: "")
    }
    
    public var cleanedUsage: String {
      draftUsage.replacingOccurrences(of: ",", with: "")
    }
    
    public var isSaveEnabled: Bool {
      let hasChanges = draftCategory != initialCategory ||
                       draftPrice != initialPrice ||
                       draftUsage != initialUsage ||
                       draftUnit != initialUnit
      let isNotEmpty = !draftPrice.isEmpty && !draftUsage.isEmpty
      return hasChanges && isNotEmpty
    }
  }

  public enum Action: Equatable {
    case draftCategoryChanged(String)
    case draftPriceChanged(String)
    case draftUsageChanged(String)
    case unitSelected(IngredientUnit)
    case saveTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .draftCategoryChanged(category):
        state.draftCategory = category
        return .none
      case let .draftPriceChanged(price):
        state.draftPrice = Self.sanitizedDigitsAndCommas(price)
        return .none
      case let .draftUsageChanged(usage):
        state.draftUsage = Self.sanitizedDigitsAndCommas(usage)
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

private extension IngredientEditSheetFeature {
  static func sanitizedDigitsAndCommas(_ value: String) -> String {
    value.filter { $0.isNumber || $0 == "," }
  }
}
