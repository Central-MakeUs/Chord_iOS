import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuPriceEditSheetView: View {
  let store: StoreOf<MenuPriceEditSheetFeature>
  let onComplete: (String) -> Void

  public init(
    store: StoreOf<MenuPriceEditSheetFeature>,
    onComplete: @escaping (String) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        SheetDragHandle()

        VStack(alignment: .leading, spacing: 24) {
          Text("가격을 입력해주세요")
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.grayscale900)

          PriceInputField(
            text: viewStore.binding(
              get: \.draftPrice,
              send: MenuPriceEditSheetFeature.Action.draftPriceChanged
            ),
            placeholder: "가격 입력",
            height: 47,
            backgroundColor: .clear
          )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        let trimmed = viewStore.draftPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !trimmed.isEmpty
        BottomButton(
          title: "완료",
          style: isEnabled ? .primary : .secondary
        ) {
          guard isEnabled else { return }
          viewStore.send(.saveTapped)
          onComplete(formattedPrice(trimmed))
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
    .presentationCornerRadius(24)
  }

  private func formattedPrice(_ value: String) -> String {
    let digits = value.filter { $0.isNumber }
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
  }
}

#Preview {
  MenuPriceEditSheetView(
    store: Store(initialState: MenuPriceEditSheetFeature.State(draftPrice: "5,600")) {
      MenuPriceEditSheetFeature()
    },
    onComplete: { _ in }
  )
  .environment(\.colorScheme, .light)
}
