import Foundation

public enum IngredientUnit: String, CaseIterable, Hashable {
  case ml = "ml"
  case g = "g"
  case count = "개"

  public var title: String { rawValue }
  
  public var serverCode: String {
    switch self {
    case .ml: return "ML"
    case .g: return "G"
    case .count: return "EA"
    }
  }

  public var baseQuantity: Double {
    switch self {
    case .ml, .g:
      return 100
    case .count:
      return 1
    }
  }

  public static func from(_ text: String) -> IngredientUnit {
    switch text.uppercased() {
    case "ML": return .ml
    case "G": return .g
    case "EA", "개": return .count
    default: return .g
    }
  }
}
