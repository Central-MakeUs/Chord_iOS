import SwiftUI

struct OnboardingDetailAddressSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var detailAddress: String
  @State private var draftAddress: String

  init(detailAddress: Binding<String>) {
    _detailAddress = detailAddress
    _draftAddress = State(initialValue: detailAddress.wrappedValue)
  }

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 24) {
        Text("상세주소를 입력해주세요")
          .font(.pretendardHeadline1)
          .foregroundColor(AppColor.grayscale900)

        UnderlinedTextField(
          text: $draftAddress,
          title: nil,
          placeholder: "층 / 호수"
        )
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      Spacer(minLength: 20)

      let isEnabled = !draftAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      BottomButton(title: "완료", style: isEnabled ? .primary : .secondary) {
        guard isEnabled else { return }
        detailAddress = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }
}

#Preview {
  OnboardingDetailAddressSheetView(detailAddress: .constant("101호"))
    .environment(\.colorScheme, .light)
}
