import SwiftUI
import UIKit

enum Pretendard {
  
  enum Weight: String, CaseIterable {
    case thin = "Pretendard-Thin"
    case extraLight = "Pretendard-ExtraLight"
    case light = "Pretendard-Light"
    case regular = "Pretendard-Regular"
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
    case extraBold = "Pretendard-ExtraBold"
    case black = "Pretendard-Black"
    
    var fontName: String { rawValue }
  }
}

extension Font {
  
  static func pretendard(
    _ size: CGFloat,
    weight: Pretendard.Weight = .regular
  ) -> Font {
    .custom(weight.fontName, size: size)
  }
}
extension Font {
  static var pretendardDisplay1: Font { PretendardTextStyle.display1.font }
  static var pretendardDisplay2: Font { PretendardTextStyle.display2.font }
  static var pretendardHeadline1: Font { PretendardTextStyle.headline1.font }
  static var pretendardHeadline2: Font { PretendardTextStyle.headline2.font }
  static var pretendardSubtitle1: Font { PretendardTextStyle.subtitle1.font }
  static var pretendardSubtitle2: Font { PretendardTextStyle.subtitle2.font }
  static var pretendardSubtitle3: Font { PretendardTextStyle.subtitle3.font }
  static var pretendardBody1: Font { PretendardTextStyle.body1.font }
  static var pretendardBody2: Font { PretendardTextStyle.body2.font }
  static var pretendardCTA: Font { PretendardTextStyle.cta.font }
  static var pretendardCaption1: Font { PretendardTextStyle.caption1.font }
  static var pretendardCaption2: Font { PretendardTextStyle.caption2.font }

  static var pretendardDisplay: Font { PretendardTextStyle.display1.font }
  static var pretendardTitle1: Font { PretendardTextStyle.headline2.font }
  static var pretendardTitle2: Font { PretendardTextStyle.subtitle1.font }
  static var pretendardSubTitle: Font { PretendardTextStyle.subtitle3.font }
  static var pretendardCaption: Font { PretendardTextStyle.caption2.font }
}
