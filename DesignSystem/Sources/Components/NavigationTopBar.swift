import SwiftUI

public struct NavigationTopBar: View {
  public let onBackTap: () -> Void
  
  public init(onBackTap: @escaping () -> Void) {
    self.onBackTap = onBackTap
  }
  
  public var body: some View {
    HStack {
      Button(action: onBackTap) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
      }
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
}

#Preview {
  NavigationTopBar(onBackTap: {})
}
