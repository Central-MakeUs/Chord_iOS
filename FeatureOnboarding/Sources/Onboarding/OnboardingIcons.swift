import SwiftUI
import DesignSystem

struct ImgComplete: View {
  var body: some View {
    ZStack {
      Circle()
        .fill(
          LinearGradient(
            colors: [Color(hex: 0x4C7DFF), Color(hex: 0xE1D4FF)],
            startPoint: .top,
            endPoint: .bottom
          )
        )

      CheckmarkStroke()
        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        .padding(20)
    }
    .frame(width: 80, height: 80)
  }
}

private struct CheckmarkStroke: Shape {
  func path(in rect: CGRect) -> Path {
    let scaleX = rect.width / 40
    let scaleY = rect.height / 25

    var path = Path()
    path.move(to: CGPoint(x: 2.57 * scaleX, y: 12.55 * scaleY))
    path.addLine(to: CGPoint(x: 15.67 * scaleX, y: 23.58 * scaleY))
    path.addLine(to: CGPoint(x: 37.02 * scaleX, y: 3.83 * scaleY))
    return path
  }
}

struct ImgCount: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 24)
        .fill(
          LinearGradient(
            colors: [Color(hex: 0x366DFF), Color.white],
            startPoint: .top,
            endPoint: .bottom
          )
        )

      VStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 12)
          .fill(
            LinearGradient(
              colors: [Color(hex: 0x555963), Color(hex: 0x496FD3)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(height: 40)
          .padding(.horizontal, 13)

        HStack(spacing: 10) {
          calculatorButton(symbol: "+")
          calculatorButton(symbol: "−")
          calculatorButton(symbol: "=")
        }
        .padding(.horizontal, 13)
      }
      .padding(.vertical, 17)
    }
    .frame(width: 145, height: 125)
  }

  private func calculatorButton(symbol: String) -> some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(
        LinearGradient(
          colors: [Color(hex: 0x9BB7FF), Color(hex: 0xDEE6FF)],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .frame(width: 27, height: 27)
      .overlay(
        Text(symbol)
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(Color(hex: 0x6586DF))
      )
  }
}

private extension Color {
  init(hex: UInt) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}
