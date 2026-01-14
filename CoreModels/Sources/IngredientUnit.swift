import Foundation

public enum IngredientUnit: String, CaseIterable, Hashable {
  case ml = "ml"
  case g = "g"
  case kg = "kg"
  case count = "개"

  public var title: String { rawValue }

  public static func from(_ text: String) -> IngredientUnit {
    switch text {
    case "ml": return .ml
    case "g": return .g
    case "kg": return .kg
    case "개": return .count
    default: return .g
    }
  }
}
