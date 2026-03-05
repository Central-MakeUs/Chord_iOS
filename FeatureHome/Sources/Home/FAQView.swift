import SwiftUI
import DesignSystem

struct FAQView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button(action: { dismiss() }) {
          Image.arrowLeftIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale900)
            .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 12)
      .padding(.bottom, 24)

      ScrollView {
        VStack(alignment: .leading, spacing: 36) {
          Text("FAQ")
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.primaryBlue500)

          faqItem(
            question: "마진율이 뭔가요?",
            answer: [
              "마진율은 재료비와 인건비를 기준으로 계산한 추정",
              "마진율이에요. 우리 가게의 운영 효율을 알려줘요."
            ]
          )

          faqItem(
            question: "원가율이 뭔가요?",
            answer: [
              "메뉴 가격 중 재료비가 차지하는 비중이에요.",
              "재료비는 식재료와 운영재료(소모품)를 모두 포함해요."
            ]
          )

          faqItem(
            question: "공헌이익이 뭔가요?",
            answer: [
              "한 잔당 판매가 만들어내는 수익을 말해요.",
              "메뉴의 운영 상의 수익률을 알 수 있는 지표로 활용돼요."
            ]
          )

          faqItem(
            question: "권장가격이 뭔가요?",
            answer: [
              "손해 없이 운영할 수 있는 최소 기준 가격을 의미해요.",
              "권장 가격 이상으로 가격을 설정해야 수익성에",
              "문제 가 없어요."
            ]
          )

          faqItemWithBullets(
            question: "수익 등급은 어떻게 설정되나요?",
            intro: [
              "수익 등급은 안정/보통/주의/위험으로 구성돼요.",
              "수익 등급은 원가율을 기준으로 다음과 같이 표시돼요."
            ],
            bullets: [
              "안정 : 원가율 25%이하",
              "보통 : 원가율 25% 초과 ~ 35% 이하",
              "주의 : 원가율 35% 초과~ 40% 이하",
              "위험 : 원가율 40% 초과"
            ]
          )

          faqItem(
            question: "AI 코치 가이드는 언제 생성되나요?",
            answer: [
              "AI 코치는 일주일에 한번, 매주 일요일 21시 59분에",
              "업데이트 됩니다."
            ]
          )

          VStack(alignment: .leading, spacing: 6) {
            Text("더 자세한 안내가 필요한 경우, 아래 이메일로 문의해 주세요.")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale600)

            Text("coach.operation@gmail.com")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale600)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }

  private func faqItem(question: String, answer: [String]) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Q. \(question)")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      ForEach(Array(answer.enumerated()), id: \.offset) { index, line in
        Text(index == 0 ? "A. \(line)" : line)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale600)
      }
    }
  }

  private func faqItemWithBullets(question: String, intro: [String], bullets: [String]) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Q. \(question)")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      ForEach(Array(intro.enumerated()), id: \.offset) { index, line in
        Text(index == 0 ? "A. \(line)" : line)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale600)
      }

      VStack(alignment: .leading, spacing: 4) {
        ForEach(bullets, id: \.self) { bullet in
          Text("  •  \(bullet)")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
        }
      }
    }
  }
}

#Preview {
  FAQView()
}
