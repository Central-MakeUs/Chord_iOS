import SwiftUI
import UIKit

enum PretendardTextStyle {
  case display1
  case display2
  case headline1
  case headline2
  case title1
  case title2
  case subtitle1
  case subtitle2
  case subtitle3
  case body1
  case body2
  case cta
  case caption
  case caption1
  case caption2

  var size: CGFloat {
    switch self {
    case .display1:  return 36
    case .display2:  return 32
    case .headline1: return 24
    case .headline2: return 22
    case .title1:    return 28
    case .title2:    return 24
    case .subtitle1: return 20
    case .subtitle2: return 20
    case .subtitle3: return 18
    case .body1:     return 16
    case .body2:     return 16
    case .cta:       return 16
    case .caption:   return 14
    case .caption1:  return 14
    case .caption2:  return 12
    }
  }

  var fontName: String {
    switch self {
    case .display1,
         .display2,
         .headline1,
         .headline2,
         .title1,
         .subtitle1,
         .subtitle3,
         .cta,
         .caption,
         .caption1:
      return "Pretendard-SemiBold"
    case .title2, .subtitle2, .body2:
      return "Pretendard-Medium"
    case .body1:
      return "Pretendard-Bold"
    case .caption2:
      return "Pretendard-Regular"
    }
  }

  var font: Font {
    if UIFont(name: fontName, size: size) != nil {
      return .custom(fontName, size: size)
    } else {
      print("⚠️ Pretendard font not available: \(fontName), using system font")
      return .system(size: size, weight: fallbackWeight)
    }
  }

  private var fallbackWeight: Font.Weight {
    if fontName.contains("Bold") {
      return .bold
    } else if fontName.contains("SemiBold") {
      return .semibold
    } else if fontName.contains("Medium") {
      return .medium
    } else if fontName.contains("Light") {
      return .light
    } else {
      return .regular
    }
  }
}
