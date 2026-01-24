import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnboardingStaffCountSheetView: View {
  let store: StoreOf<OnboardingStaffCountSheetFeature>
  let onComplete: (Int) -> Void

  public init(
    store: StoreOf<OnboardingStaffCountSheetFeature>,
    onComplete: @escaping (Int) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
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
                viewStore.send(.decrementTapped)
              }
              Text("\(viewStore.staffCount)")
                .font(.pretendardSubtitle1)
                .foregroundColor(AppColor.grayscale900)
                .frame(minWidth: 20)
              StepperButton(symbol: "+") {
                viewStore.send(.incrementTapped)
              }
            }
          }
          .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        BottomButton(title: "완료", style: .primary) {
          viewStore.send(.completeTapped)
          onComplete(viewStore.staffCount)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
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
  OnboardingStaffCountSheetView(
    store: Store(initialState: OnboardingStaffCountSheetFeature.State(staffCount: 3)) {
      OnboardingStaffCountSheetFeature()
    },
    onComplete: { _ in }
  )
  .environment(\.colorScheme, .light)
}
