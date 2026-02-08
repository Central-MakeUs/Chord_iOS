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

  public static func from(_ text: String) -> IngredientUnit {
    switch text.uppercased() {
    case "ML": return .ml
    case "G": return .g
    case "EA", "개": return .count
    default: return .g
    }
  }
}
