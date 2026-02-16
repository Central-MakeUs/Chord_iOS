import SwiftUI
import DesignSystem

public struct SplashView: View {
  public init() {}
  
  public var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()

      Image("SplashCenterLogo", bundle: .main)
        .resizable()
        .scaledToFit()
        .frame(width: 172, height: 178)
    }
  }
}

#Preview {
  SplashView()
}

public struct SignUpCompleteView: View {
  public init() {}
  
  public var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()
      
      VStack(spacing: 24) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  AppColor.primaryBlue400,
                  AppColor.primaryBlue500
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 80, height: 80)
          
          Image(systemName: "checkmark")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(.white)
        }
        
        Text("가입이 완료됐어요")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.primaryBlue500)
      }
    }
  }
}

#Preview("SignUpComplete") {
  SignUpCompleteView()
}
