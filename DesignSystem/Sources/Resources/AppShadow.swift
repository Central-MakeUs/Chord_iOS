import SwiftUI

public struct AppShadow {
  public let color: Color
  public let radius: CGFloat
  public let x: CGFloat
  public let y: CGFloat

  public static let sm = AppShadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 2)
  public static let md = AppShadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
  public static let lg = AppShadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
  public static let xl = AppShadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 4)

  public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

public extension View {
  func shadow(_ style: AppShadow) -> some View {
    shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
