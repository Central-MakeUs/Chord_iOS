import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnboardingDetailAddressSheetView: View {
  let store: StoreOf<OnboardingDetailAddressSheetFeature>
  let onComplete: (String) -> Void

  public init(
    store: StoreOf<OnboardingDetailAddressSheetFeature>,
    onComplete: @escaping (String) -> Void
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

        VStack(alignment: .leading, spacing: 24) {
          Text("상세주소를 입력해주세요")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)

          UnderlinedTextField(
            text: viewStore.binding(
              get: \.draftAddress,
              send: OnboardingDetailAddressSheetFeature.Action.draftAddressChanged
            ),
            title: nil,
            placeholder: "층 / 호수"
          )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        let trimmed = viewStore.draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !trimmed.isEmpty
        BottomButton(title: "완료", style: isEnabled ? .primary : .secondary) {
          guard isEnabled else { return }
          viewStore.send(.saveTapped)
          onComplete(trimmed)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
  }
}

#Preview {
  OnboardingDetailAddressSheetView(
    store: Store(initialState: OnboardingDetailAddressSheetFeature.State(draftAddress: "101호")) {
      OnboardingDetailAddressSheetFeature()
    },
    onComplete: { _ in }
  )
  .environment(\.colorScheme, .light)
}
