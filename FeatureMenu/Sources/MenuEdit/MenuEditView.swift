import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuEditView: View {
  let store: StoreOf<MenuEditFeature>
  @Environment(\.dismiss) private var dismiss
  @State private var isCategorySheetPresented = false
  @State private var selectedCategoryDraft: MenuCategory = .beverage

  public init(store: StoreOf<MenuEditFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        VStack(spacing: 0) {
          NavigationTopBar(
            onBackTap: { dismiss() },
            title: ""
          )

          VStack(alignment: .leading, spacing: 24) {
            menuNameSection(
              name: viewStore.binding(
                get: \.menuName,
                send: MenuEditFeature.Action.menuNameUpdated
              )
            )

            priceSection(
              viewStore: viewStore,
              price: viewStore.binding(
                get: \.menuPrice,
                send: MenuEditFeature.Action.menuPriceUpdated
              )
            )

            categoryAndTimeSection(viewStore: viewStore)

            Spacer()

            BottomButton(
              title: "수정 완료",
              style: viewStore.hasPendingChanges && !viewStore.isUpdating ? .primary : .secondary
            ) {
              viewStore.send(.completeEditTapped)
            }
            .disabled(!viewStore.hasPendingChanges || viewStore.isUpdating)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 24)
        }
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .sheet(
        isPresented: viewStore.binding(
          get: \.isPrepareTimePresented,
          send: MenuEditFeature.Action.prepareTimePresented
        )
      ) {
        PrepareTimeSheetView(
          store: Store(
            initialState: PrepareTimeSheetFeature.State(
              minutes: viewStore.prepareTimeMinutes,
              seconds: viewStore.prepareTimeSeconds
            )
          ) {
            PrepareTimeSheetFeature()
          },
          onComplete: { minutes, seconds in
            viewStore.send(.prepareTimeUpdated(minutes: minutes, seconds: seconds))
          }
        )
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
      .sheet(isPresented: $isCategorySheetPresented) {
        MenuEditCategoryBottomSheet(
          selectedCategory: $selectedCategoryDraft,
          categories: viewStore.categories,
          onConfirm: {
            viewStore.send(.categorySelected(selectedCategoryDraft))
            isCategorySheetPresented = false
          }
        )
        .presentationDetents([.height(300)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.white)
      }
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.isDeleteConfirmPresented,
          send: { _ in MenuEditFeature.Action.deleteCancelTapped }
        ),
        title: "메뉴를 삭제하시겠어요?",
        alertType: .twoButton,
        leftButtonTitle: "아니요",
        rightButtonTitle: "삭제하기",
        leftButtonAction: { viewStore.send(.deleteCancelTapped) },
        rightButtonAction: { viewStore.send(.deleteConfirmTapped) }
      )
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.isDeleteSuccessPresented,
          send: { _ in MenuEditFeature.Action.deleteSuccessTapped }
        ),
        title: "메뉴가 삭제 됐어요",
        alertType: .oneButton,
        rightButtonTitle: "확인",
        rightButtonAction: { viewStore.send(.deleteSuccessTapped) }
      )
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.isUpdateSuccessPresented,
          send: { _ in MenuEditFeature.Action.updateSuccessDismissed }
        ),
        message: "수정이 반영되었어요!"
      )
      .onChange(of: viewStore.isUpdateSuccessPresented) { isPresented in
        guard isPresented else { return }
        viewStore.send(.updateSuccessDismissed)
        dismiss()
      }
    }
  }

  private func menuNameSection(name: Binding<String>) -> some View {
    UnderlinedTextField(
      text: name,
      title: "메뉴명",
      placeholder: "메뉴명 입력",
      titleColor: AppColor.grayscale700,
      placeholderColor: AppColor.grayscale400,
      underlineColor: AppColor.grayscale300,
      accentColor: AppColor.primaryBlue500
    )
  }

  private func priceSection(viewStore: ViewStoreOf<MenuEditFeature>, price: Binding<String>) -> some View {
    UnderlinedTextField(
      text: price,
      title: "가격",
      placeholder: "가격 입력",
      titleColor: AppColor.grayscale700,
      placeholderColor: AppColor.grayscale400,
      underlineColor: AppColor.grayscale300,
      accentColor: AppColor.primaryBlue500,
      keyboardType: .decimalPad
    )
    .contentShape(Rectangle())
    .onTapGesture {
      viewStore.send(.menuPriceFieldTapped)
    }
  }

  private func categoryAndTimeSection(viewStore: ViewStoreOf<MenuEditFeature>) -> some View {
    HStack(spacing: 8) {
      infoSelectCard(
        title: "카테고리",
        value: viewStore.selectedCategory.title
      ) {
        selectedCategoryDraft = viewStore.selectedCategory
        isCategorySheetPresented = true
      }

      infoSelectCard(
        title: "제조시간",
        value: viewStore.prepareTime
      ) {
        viewStore.send(.prepareTimeTapped)
      }
    }
  }

  private func infoSelectCard(
    title: String,
    value: String,
    onTap: @escaping () -> Void
  ) -> some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 12) {
        Text(title)
          .frame(minHeight: 26)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale600)

        HStack(spacing: 4) {
          Text(value)
            .font(.pretendardSubtitle4)
            .foregroundColor(AppColor.grayscale600)
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
        }
        .frame(minHeight: 26)
      }
      .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
      .padding(12)
      .background(AppColor.grayscale200)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    .buttonStyle(.plain)
  }

}

private struct MenuEditCategoryBottomSheet: View {
  @Binding var selectedCategory: MenuCategory
  let categories: [MenuCategory]
  let onConfirm: () -> Void

  var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Text("메뉴 카테고리")
          .font(.pretendardSubtitle1)
          .foregroundColor(AppColor.grayscale900)
          .padding(.top, 20)
          .padding(.bottom, 16)

        VStack(alignment: .leading, spacing: 20) {
          ForEach(categories, id: \.self) { category in
            Button(action: { selectedCategory = category }) {
              HStack(spacing: 8) {
                Text(category.title)
                  .font(.pretendardBody2)
                  .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale900)

                if selectedCategory == category {
                  Image.checkmarkIcon
                    .renderingMode(.template)
                    .foregroundColor(AppColor.primaryBlue500)
                    .frame(width: 16, height: 16)
                }

                Spacer()
              }
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 24)

        Spacer(minLength: 12)

        BottomButton(title: "확인", style: .primary) {
          onConfirm()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
      }
    }
  }
}

private struct SheetCornerRadiusModifier: ViewModifier {
  let radius: CGFloat

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 16.4, *) {
      content.presentationCornerRadius(radius)
    } else {
      content
    }
  }
}

#Preview {
  MenuEditView(
    store: Store(
      initialState: MenuEditFeature.State(
        item: MenuItem(
          name: "돌체라떼",
          price: "5,600원",
          category: .beverage,
          status: .danger,
          costRate: "62.9%",
          marginRate: "23.2%",
          costAmount: "1,200원",
          contribution: "3,670원",
          ingredients: [],
          totalIngredientCost: "1,450원"
        )
      )
    ) {
      MenuEditFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
