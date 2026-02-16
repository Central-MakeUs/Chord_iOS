import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationConfirmationView: View {
  let store: StoreOf<MenuRegistrationFeature>

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(
          onBackTap: { viewStore.send(.previousStepTapped) },
          title: ""
        )

        ScrollView {
          VStack(spacing: 40) {
            Text("이대로 등록을 마칠까요?")
              .font(.pretendardHeadline1)
              .foregroundColor(AppColor.grayscale900)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.top, 20)

            menuSummaryCard(viewStore: viewStore)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 40)
        }

        bottomButtons(viewStore: viewStore)
      }
      .background(Color.white.ignoresSafeArea())
      .navigationBarBackButtonHidden(true)
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.showDupMenuAlert,
          send: { _ in .dupMenuAlertCancelled }
        ),
        title: "동일한 메뉴명이 이미 존재합니다.\n해당 메뉴를 추가하시겠습니까?",
        alertType: .twoButton,
        leftButtonTitle: "아니오",
        rightButtonTitle: "네",
        leftButtonAction: { viewStore.send(.dupMenuAlertCancelled) },
        rightButtonAction: { viewStore.send(.dupMenuAlertConfirmed) }
      )
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.showDupIngredientAlert,
          send: { _ in .dupIngredientAlertCancelled }
        ),
        title: "동일한 재료명이 이미 존재합니다.\n해당 재료를 추가하시겠습니까?",
        alertType: .twoButton,
        leftButtonTitle: "아니오",
        rightButtonTitle: "네",
        leftButtonAction: { viewStore.send(.dupIngredientAlertCancelled) },
        rightButtonAction: { viewStore.send(.dupIngredientAlertConfirmed) }
      )
    }
  }

  private func menuSummaryCard(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 24) {
      VStack(spacing: 12) {
        Text("메뉴 1")
          .font(.pretendardCaption1)
          .foregroundColor(.white)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(AppColor.primaryBlue500)
          .cornerRadius(8)

        Text(viewStore.menuName)
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)

        if !viewStore.price.isEmpty {
          Text("\(viewStore.price)원")
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale700)
        }
      }

      VStack(spacing: 12) {
        ForEach(viewStore.addedIngredients) { item in
          HStack {
            Text(item.name)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)

            Spacer()

            Text("\(item.formattedAmount)/\(item.formattedPrice)")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)
          }
        }
      }
      .padding(.top, 12)
    }
    .padding(.vertical, 40)
    .padding(.horizontal, 24)
    .background(AppColor.primaryBlue100.opacity(0.3))
    .cornerRadius(24)
    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
  }

  private func bottomButtons(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    HStack(spacing: 12) {
      BottomButton(
        title: "추가 등록",
        style: .secondary
      ) {
        viewStore.send(.addMoreTapped)
      }

      BottomButton(
        title: "마치기",
        style: .primary
      ) {
        viewStore.send(.finalCompleteTapped)
      }
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 24)
    .padding(.top, 16)
    .background(Color.white)
  }
}
