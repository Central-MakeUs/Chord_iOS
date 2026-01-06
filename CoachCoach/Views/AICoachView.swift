import SwiftUI

struct AICoachView: View {
  private let strategyCards = [
    StrategyCardModel(title: "바닐라 라떼", subtitle: "가격 조정 제안"),
    StrategyCardModel(title: "바닐라 라떼", subtitle: "가격 조정 제안"),
    StrategyCardModel(title: "바닐라 라떼", subtitle: "가격 조정 제안")
  ]

  var body: some View {
    ZStack {
      AppColor.primaryBlue100
        .ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          topBar
          heroSection
          BottomButton(title: "전략 카드 생성하기", height: 44, style: .primary) {}
          strategySection
          Text("받은 전략\n실행해볼까요?")
            .font(.pretendardSubTitle)
            .foregroundColor(AppColor.grayscale900)
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
      }
    }
  }
  
  private var topBar: some View {
    HStack {
      Button(action: {}) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)
      Spacer()
    }
    .padding(.bottom, 8)
  }
  
  private var heroSection: some View {
    Text("내 매장에 전략을 더하고\n더 똑똑하게 관리해보세요")
      .font(.pretendardBody2)
      .foregroundColor(AppColor.grayscale900)
      .multilineTextAlignment(.center)
      .lineSpacing(4)
      .frame(maxWidth: .infinity)
      .padding(.bottom, 2)
  }
  
  private var strategySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("오늘의 우리 매장 전략")
        .font(.pretendardBody1)
        .foregroundColor(AppColor.grayscale900)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(strategyCards) { card in
            AICoachStrategyCard(model: card)
          }
        }
        .padding(.vertical, 4)
      }
    }
  }
}

private struct StrategyCardModel: Identifiable {
  let id = UUID()
  let title: String
  let subtitle: String
}

private struct AICoachStrategyCard: View {
  let model: StrategyCardModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(model.title)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.primaryBlue500)
      Text(model.subtitle)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.primaryBlue500)
    }
    .padding(12)
    .frame(width: 110, height: 84, alignment: .topLeading)
    .background(AppColor.grayscale100)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(AppColor.grayscale200, lineWidth: 1)
    )
  }
}

#Preview {
  AICoachView()
    .environment(\.colorScheme, .light)
}
