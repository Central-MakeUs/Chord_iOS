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
    static var pretendardDisplay: Font { PretendardTextStyle.display.font }
    static var pretendardTitle1: Font { PretendardTextStyle.title1.font }
    static var pretendardTitle2: Font { PretendardTextStyle.title2.font }
    static var pretendardSubTitle: Font { PretendardTextStyle.subTitle.font }
    static var pretendardBody1: Font { PretendardTextStyle.body1.font }
    static var pretendardBody2: Font { PretendardTextStyle.body2.font }
    static var pretendardCaption: Font { PretendardTextStyle.caption.font }
    static var pretendardCTA: Font { PretendardTextStyle.cta.font }
}
