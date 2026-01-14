import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationView: View {
  let store: StoreOf<MenuRegistrationFeature>

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        VStack(spacing: 0) {
          ScrollView {
            VStack(alignment: .leading, spacing: 24) {
              topBar(onBack: { viewStore.send(.backTapped) })

              UnderlinedTextField(
                text: viewStore.binding(
                  get: \.menuName,
                  send: MenuRegistrationFeature.Action.menuNameChanged
                ),
                title: "메뉴명",
                placeholder: "메뉴의 이름을 입력해주세요",
                titleColor: AppColor.primaryBlue500,
                trailingIcon: Image.searchIcon
              )

              UnderlinedTextField(
                text: viewStore.binding(
                  get: \.price,
                  send: MenuRegistrationFeature.Action.priceChanged
                ),
                title: "가격",
                placeholder: "가격을 입력해주세요",
                keyboardType: .numberPad
              )

              categorySection(
                selected: viewStore.selectedCategory,
                onSelect: { viewStore.send(.categorySelected($0)) }
              )

              VStack(alignment: .leading, spacing: 8) {
                Text("제조시간")
                  .font(.pretendardBody2)
                  .foregroundColor(AppColor.grayscale900)
              }

              ingredientSection(
                ingredients: viewStore.ingredients,
                onAdd: { viewStore.send(.addIngredientTapped) }
              )
            }
            .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
          }

          BottomButton(title: "완료", style: .primary) {
            viewStore.send(.completeTapped)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 24)
        }
      }
    }
  }

  private func topBar(onBack: @escaping () -> Void) -> some View {
    ZStack {
      HStack {
        Button(action: onBack) {
          Image.arrowLeftIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale900)
            .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        Spacer()
      }

      Text("메뉴등록")
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
    }
  }

  private func categorySection(
    selected: MenuRegistrationFeature.Category,
    onSelect: @escaping (MenuRegistrationFeature.Category) -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("카테고리")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        ForEach(MenuRegistrationFeature.Category.allCases, id: \.self) { category in
          Button(action: { onSelect(category) }) {
            Text(category.rawValue)
              .font(.pretendardCaption1)
              .foregroundColor(selected == category ? AppColor.primaryBlue500 : AppColor.grayscale600)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(
                RoundedRectangle(cornerRadius: 14)
                  .fill(selected == category ? AppColor.primaryBlue100 : AppColor.grayscale100)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(selected == category ? AppColor.primaryBlue500 : AppColor.grayscale300, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private func ingredientSection(
    ingredients: [String],
    onAdd: @escaping () -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("재료")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Spacer()
        Button(action: onAdd) {
          HStack(spacing: 4) {
            Text("추가")
              .font(.pretendardCaption1)
            Text("+")
              .font(.pretendardCaption1)
          }
          .foregroundColor(AppColor.grayscale100)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(AppColor.primaryBlue500)
          )
        }
        .buttonStyle(.plain)
      }

      VStack(alignment: .leading, spacing: 8) {
        ForEach(ingredients, id: \.self) { item in
          Text(item)
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
      }
    }
    .padding(16)
    .background(AppColor.grayscale200)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  MenuRegistrationView(
    store: Store(initialState: MenuRegistrationFeature.State()) {
      MenuRegistrationFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
