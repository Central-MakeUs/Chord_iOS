import SwiftUI
import DesignSystem

public struct SplashView: View {
  public init() {}
  
  public var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()
      
      VStack(spacing: 16) {
        Image.aiCoachIcon
          .resizable()
          .renderingMode(.template)
          .foregroundColor(AppColor.primaryBlue500)
          .frame(width: 80, height: 80)
        
        Text("코치코치")
          .font(.pretendardDisplay1)
          .foregroundColor(AppColor.primaryBlue500)
      }
    }
  }
}

#Preview {
  SplashView()
}
