import SwiftUI

enum PretendardTextStyle {
  case display
  case title1
  case title2
  case subTitle
  case body1
  case body2
  case caption
  case cta
  
  var size: CGFloat {
    switch self {
    case .display:  return 36
    case .title1:   return 22
    case .title2:   return 20
    case .subTitle: return 18
    case .body1:    return 16
    case .body2:    return 14
    case .caption:  return 12
    case .cta:      return 16
    }
  }
  
  var weight: Pretendard.Weight {
    switch self {
    case .display:
      return .bold          // 700
    case .title1, .title2, .cta:
      return .semiBold      // 600
    case .subTitle:
      return .medium        // 500
    case .body1, .body2:
      return .regular       // 400
    case .caption:
      return .medium
    }
  }
  
  var font: Font {
    .pretendard(size, weight: weight)
  }
}
