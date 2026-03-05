import SwiftUI
import DesignSystem

struct TermsOfServiceView: View {
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
        VStack(alignment: .leading, spacing: 22) {
          Text("코치코치 서비스 이용약관")
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)

          Text("구성 개요")
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale900)

          VStack(alignment: .leading, spacing: 10) {
            Text("1. 목적 및 정의")
            Text("2. 회원 가입 및 계정 관리")
            Text("3. 서비스 내용 및 제공 범위")
            Text("4. 사용자 입력 정보의 책임")
            Text("5. 서비스 이용의 제한 및 중단")
            Text("6. 지식재산권")
            Text("7. 책임의 제한 및 면책")
            Text("8. 계약 해지 및 회원 탈퇴")
            Text("9. 약관의 변경")
            Text("10. 준거법 및 분쟁 해결")
          }
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
          .padding(.leading, 20)

          Text("항목별 핵심 내용 가이드")
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale900)

          termsSection(
            title: "1. 목적 및 정의",
            bullets: [
              "본 약관은 코치코치앱(이하 \"서비스\")의 이용 조건\n및 절차, 권리·의무를 규정함",
              "서비스는 카페 운영에 필요한 원가·수익성 분석을\n돕기 위한 참고용 정보 제공 목적임",
              "계산 결과는 법적·세무적·회계적 자문이 아님"
            ]
          )

          termsSection(
            title: "2. 회원 가입 및 계정 관리",
            bullets: [
              "회원은 정확한 정보를 입력해야 함",
              "계정 정보 관리 책임은 사용자에게 있음",
              "타인의 계정 사용, 양도, 대여 금지"
            ]
          )

          termsSection(
            title: "3. 서비스 내용 및 제공 범위",
            bullets: [
              "사용자가 입력한 메뉴, 재료비, 비용 정보를\n바탕으로 원가, 마진율, 공헌이익, 권장 가격 등의\n분석 정보를 제공",
              "서비스 내용은 운영 정책에 따라 변경·추가·\n중단될 수 있음"
            ]
          )

          termsSection(
            title: "4. 사용자 입력 정보의 책임",
            bullets: [
              "모든 분석 결과는 사용자가 입력한 정보에 의존",
              "입력 정보의 정확성, 최신성에 대한 책임은\n사용자에게 있음",
              "잘못된 입력으로 인한 손실에 대해 서비스는\n책임을 지지 않음"
            ]
          )

          termsSection(
            title: "5. 서비스 이용의 제한 및 중단",
            bullets: [
              "시스템 점검, 장애, 불가항력 사유 시 서비스가\n일시 중단될 수 있음",
              "회사는 사전 공지 후 또는 불가피한 경우 사후\n공지로 서비스 중단 가능"
            ]
          )

          termsSection(
            title: "6. 지식재산권",
            bullets: [
              "서비스에 포함된 UI, 콘텐츠, 분석 로직, 계산 방식의\n저작권은 회사에 귀속",
              "사용자는 개인적인 서비스 이용 범위 내에서만\n사용 가능"
            ]
          )

          termsSection(
            title: "7. 책임의 제한 및 면책",
            bullets: [
              "서비스에서 제공되는 분석, 가이드, 권장 가격은\n의사결정을 돕는 참고 자료",
              "실제 경영 판단, 손익 결과에 대한 책임은\n사용자에게 있음",
              "회사는 간접 손해, 영업 손실, 기대 수익 손실에\n대해 책임을 지지 않음",
              "서비스의 일부 기능은 자동화된 분석 또는 AI 기반\n로직을 활용함",
              "AI 분석 결과는 참고용 정보이며, 항상 정확하거나\n최신임을 보장하지 않음",
              "AI 결과에 대한 최종 판단 및 책임은 사용자에게\n있음"
            ]
          )

          termsSection(
            title: "8. 계약 해지 및 회원 탈퇴",
            bullets: [
              "사용자는 언제든지 앱 내 기능을 통해 회원 탈퇴\n가능",
              "탈퇴 시 관련 법령에 따라 일부 정보는 보관될 수\n있음",
              "(※ 구체적 보관 내용은 개인정보 처리방침에 위임)"
            ]
          )

          termsSection(
            title: "9. 약관의 변경",
            bullets: [
              "약관 변경 시 앱 내 공지 또는 기타 합리적인\n방법으로 고지",
              "변경 후에도 서비스를 계속 이용할 경우 동의로\n간주"
            ]
          )

          termsSection(
            title: "10. 준거법 및 분쟁 해결",
            bullets: [
              "본 약관은 대한민국 법을 준거법으로 함"
            ]
          )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }

  private func termsSection(title: String, bullets: [String]) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      VStack(alignment: .leading, spacing: 8) {
        ForEach(bullets, id: \.self) { bullet in
          HStack(alignment: .top, spacing: 6) {
            Text("•")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale900)

            Text(bullet)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale900)
              .lineSpacing(4)
          }
        }
      }
    }
  }
}

#Preview {
  TermsOfServiceView()
}
