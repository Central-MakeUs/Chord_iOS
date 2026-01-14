import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationStartView: View {
  let store: StoreOf<MenuRegistrationStartFeature>

  public init(store: StoreOf<MenuRegistrationStartFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        VStack(spacing: 0) {
          Spacer()

          Text("메뉴를 등록해주시면\n원가와 마진을 계산해드릴게요")
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)
            .multilineTextAlignment(.center)
            .lineSpacing(4)

          Spacer()

          Button(action: { viewStore.send(.skipTapped) }) {
            Text("서비스 미리 둘러보기")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale500)
          }
          .buttonStyle(.plain)
          .padding(.bottom, 12)

          BottomButton(title: "메뉴 등록 시작하기", style: .primary) {
            viewStore.send(.startTapped)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
    }
  }
}

#Preview {
  MenuRegistrationStartView(
    store: Store(initialState: MenuRegistrationStartFeature.State()) {
      MenuRegistrationStartFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
