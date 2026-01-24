import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct IngredientSupplierSheetView: View {
  let store: StoreOf<IngredientSupplierSheetFeature>
  let onComplete: (String) -> Void

  public init(
    store: StoreOf<IngredientSupplierSheetFeature>,
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

        VStack(alignment: .center, spacing: 24) {
          Text("공급업체")
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)

          ClearableInputField(
            text: viewStore.binding(
              get: \.draftName,
              send: IngredientSupplierSheetFeature.Action.draftNameChanged
            ),
            placeholder: "공급업체명 입력",
            height: 47,
            backgroundColor: .clear
          )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        let trimmed = viewStore.draftName.trimmingCharacters(in: .whitespacesAndNewlines)
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
  IngredientSupplierSheetView(
    store: Store(initialState: IngredientSupplierSheetFeature.State(draftName: "쿠팡")) {
      IngredientSupplierSheetFeature()
    },
    onComplete: { _ in }
  )
  .environment(\.colorScheme, .light)
}
