import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuNameEditSheetView: View {
  let store: StoreOf<MenuNameEditSheetFeature>
  let onComplete: (String) -> Void

  public init(
    store: StoreOf<MenuNameEditSheetFeature>,
    onComplete: @escaping (String) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 0) {
        Capsule()
          .fill(AppColor.grayscale300)
          .frame(width: 60, height: 6)
          .padding(.top, 12)

        VStack(alignment: .center, spacing: 24) {
          Text("메뉴명")
            .font(.pretendardHeadline1)
            .foregroundColor(AppColor.grayscale900)

          ClearableInputField(
            text: viewStore.binding(
              get: \.draftName,
              send: MenuNameEditSheetFeature.Action.draftNameChanged
            ),
            placeholder: "다른 이름 입력",
            height: 47,
            backgroundColor: .clear
          )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        let trimmed = viewStore.draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = !trimmed.isEmpty
        BottomButton(
          title: "완료",
          style: isEnabled ? .primary : .secondary
        ) {
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
  MenuNameEditSheetView(
    store: Store(initialState: MenuNameEditSheetFeature.State(draftName: "돌체라떼")) {
      MenuNameEditSheetFeature()
    },
    onComplete: { _ in }
  )
  .environment(\.colorScheme, .light)
}
