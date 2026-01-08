import SwiftUI

struct OnboardingStaffCountSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var staffCount: Int
  let onComplete: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 12) {
        Text("현재 근무중인 직원수를 알려주세요")
          .font(.pretendardHeadline1)
          .foregroundColor(AppColor.grayscale900)

        Text("언제든지 수정할 수 있어요")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)

        HStack(spacing: 8) {
          HStack(spacing: 4) {
            Text("직원수")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)
            Image.infoFilledIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale500)
              .frame(width: 14, height: 14)
          }
          Spacer()
          HStack(spacing: 8) {
            StepperButton(symbol: "-") {
              staffCount = max(1, staffCount - 1)
            }
            Text("\(staffCount)")
              .font(.pretendardSubtitle1)
              .foregroundColor(AppColor.grayscale900)
              .frame(minWidth: 20)
            StepperButton(symbol: "+") {
              staffCount += 1
            }
          }
        }
        .padding(.top, 12)
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      Spacer(minLength: 20)

      BottomButton(title: "완료", style: .primary) {
        dismiss()
        onComplete()
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }
}

private struct StepperButton: View {
  let symbol: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(symbol)
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale700)
        .frame(width: 32, height: 32)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(AppColor.grayscale100)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(AppColor.grayscale300, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  OnboardingStaffCountSheetView(staffCount: .constant(3)) {}
    .environment(\.colorScheme, .light)
}
