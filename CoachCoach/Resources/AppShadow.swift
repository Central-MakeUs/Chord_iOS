import SwiftUI

struct AppShadow {
  let color: Color
  let radius: CGFloat
  let x: CGFloat
  let y: CGFloat

  static let sm = AppShadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 2)
  static let md = AppShadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
  static let lg = AppShadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
  static let xl = AppShadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 4)
}

extension View {
  func shadow(_ style: AppShadow) -> some View {
    shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
