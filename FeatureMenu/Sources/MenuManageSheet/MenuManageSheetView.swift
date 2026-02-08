import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuManageSheetView: View {
  let store: StoreOf<MenuManageSheetFeature>
  let onComplete: () -> Void

  public init(store: StoreOf<MenuManageSheetFeature>, onComplete: @escaping () -> Void) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        SheetDragHandle()

        VStack(alignment: .leading, spacing: 24) {
          Text("메뉴 관리")
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.grayscale900)

          VStack(alignment: .leading, spacing: 12) {
            TagInputField(
              text: viewStore.binding(
                get: \.tagText,
                send: MenuManageSheetFeature.Action.tagTextChanged
              ),
              placeholder: "메뉴 태그 직접 작성하기",
              height: 47,
              backgroundColor: .clear,
              onTapAdd: { viewStore.send(.addTagTapped) }
            )

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(viewStore.tags, id: \.self) { option in
                  MenuTagChip(title: option) {
                    viewStore.send(.removeTagTapped(option))
                  }
                }
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        let isEnabled = viewStore.hasChanges ||
          !viewStore.tagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        BottomButton(
          title: "완료",
          style: isEnabled ? .primary : .secondary
        ) {
          guard isEnabled else { return }
          viewStore.send(.addTagTapped)
          viewStore.send(.completeTapped)
          onComplete()
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
}

private struct MenuTagChip: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        Text(title)
          .font(.pretendardCTA)
          .foregroundColor(AppColor.grayscale600)

        Image.cancelRoundedIcon
          .resizable()
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale600)
          .scaledToFit()
          .frame(width: 16, height: 16)
      }
      .padding(.leading, 16)
      .padding(.trailing, 8)
      .padding(.vertical, 6)
      .frame(height: 36)
      .background(
        Capsule()
          .fill(AppColor.grayscale100)
      )
      .overlay(
        Capsule()
          .strokeBorder(AppColor.grayscale600, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  MenuManageSheetView(
    store: Store(initialState: MenuManageSheetFeature.State()) {
      MenuManageSheetFeature()
    },
    onComplete: {}
  )
  .environment(\.colorScheme, .light)
}
