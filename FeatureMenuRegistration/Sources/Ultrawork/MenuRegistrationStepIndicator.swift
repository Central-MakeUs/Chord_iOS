import SwiftUI
import DesignSystem

struct MenuRegistrationStepIndicator: View {
  enum Phase {
    case step1
    case step2
  }

  let phase: Phase

  var body: some View {
    HStack(spacing: 2) {
      firstStepNode

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 2)

      Circle()
        .fill(phase == .step2 ? AppColor.primaryBlue500 : AppColor.grayscale300)
        .frame(width: 24, height: 24)
        .overlay(
          Text("2")
            .font(phase == .step2 ? .pretendardCaption2.weight(.semibold) : .pretendardCaption2)
            .foregroundColor(phase == .step2 ? .white : AppColor.grayscale500)
        )
    }
    .frame(width: 70)
  }

  @ViewBuilder
  private var firstStepNode: some View {
    Circle()
      .fill(phase == .step1 ? AppColor.primaryBlue500 : AppColor.grayscale300)
      .frame(width: 24, height: 24)
      .overlay {
        Text("1")
          .font(.pretendardCaption2)
          .foregroundColor(phase == .step1 ? .white : AppColor.grayscale500)
      }
  }
}
