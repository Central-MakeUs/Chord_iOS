import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuIngredientsView: View {
  let store: StoreOf<MenuIngredientsFeature>
  @Environment(\.dismiss) private var dismiss
  
  public init(store: StoreOf<MenuIngredientsFeature>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        HStack {
          Button(action: { dismiss() }) {
            Image.arrowLeftIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 20, height: 20)
          }
          .buttonStyle(.plain)
          
          Spacer()
          
          Text(viewStore.menuName)
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
          
          Spacer()
          
          if viewStore.isEditMode {
            Button(action: {
              viewStore.send(.deleteTapped)
            }) {
              Text("취소")
                .font(.pretendardCTA)
                .foregroundColor(AppColor.grayscale600)
            }
            .buttonStyle(.plain)
          } else {
            Button(action: {
              viewStore.send(.manageTapped)
            }) {
              Image.meatballIcon
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        
        ScrollView {
          VStack(spacing: 0) {
            ForEach(viewStore.ingredients) { ingredient in
              ingredientRow(ingredient: ingredient, viewStore: viewStore)
              
              if ingredient.id != viewStore.ingredients.last?.id {
                Divider()
                  .background(AppColor.grayscale300)
                  .padding(.leading, 20)
              }
            }
          }
        }
      }
      .background(Color.white.ignoresSafeArea())
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .overlay(alignment: .bottom) {
        if viewStore.isEditMode {
          deleteBottomBar(
            selectedCount: viewStore.selectedIngredients.count,
            isDeleting: viewStore.isLoading,
            onDelete: { viewStore.send(.deleteButtonTapped) }
          )
        }
      }
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.showToast,
          send: MenuIngredientsFeature.Action.showToastChanged
        ),
        message: viewStore.toastMessage,
        duration: 1.0
      )
      .sheet(
        isPresented: viewStore.binding(
          get: \.showAddSheet,
          send: MenuIngredientsFeature.Action.addSheetPresented
        )
      ) {
        AddIngredientSheet { newIngredient in
          viewStore.send(.ingredientAdded(newIngredient))
        }
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.showIngredientDetailSheet,
          send: MenuIngredientsFeature.Action.ingredientDetailSheetPresented
        )
      ) {
        ingredientDetailSheet(viewStore: viewStore)
          .presentationDetents([.height(420)])
          .presentationDragIndicator(.hidden)
          .presentationCornerRadius(24)
      }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .overlay {
        if viewStore.isLoading {
          ProgressView()
        }
      }
      .overlay(alignment: .topTrailing) {
        if viewStore.isManageMenuPresented {
          ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.001)
              .ignoresSafeArea()
              .onTapGesture {
                viewStore.send(.manageMenuDismissed)
              }
            
            VStack(spacing: 0) {
              Button {
                viewStore.send(.addTapped)
              } label: {
                Text("추가")
                  .font(.pretendardBody3)
                  .foregroundColor(AppColor.grayscale900)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .frame(height: 40)
              .buttonStyle(.plain)
              
              Divider()
                .background(AppColor.grayscale200)
              
              Button {
                viewStore.send(.deleteTapped)
              } label: {
                Text("삭제")
                  .font(.pretendardBody3)
                  .foregroundColor(AppColor.semanticWarningText)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .frame(height: 40)
              .buttonStyle(.plain)
            }
            .frame(width: 76, height: 80)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.top, 50)
            .padding(.trailing, 20)
          }
        }
      }
    }
  }

  private func deleteBottomBar(
    selectedCount: Int,
    isDeleting: Bool,
    onDelete: @escaping () -> Void
  ) -> some View {
    VStack(spacing: 0) {
      BottomButton(
        title: selectedCount > 0 ? "\(selectedCount)개 삭제" : "삭제",
        style: selectedCount > 0 && !isDeleting ? .primary : .secondary
      ) {
        onDelete()
      }
      .disabled(selectedCount == 0 || isDeleting)
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 12)
    }
    .background(Color.white)
  }
  
  private func ingredientRow(ingredient: IngredientItem, viewStore: ViewStoreOf<MenuIngredientsFeature>) -> some View {
    Button {
      if viewStore.isEditMode {
        viewStore.send(.ingredientToggled(ingredient.id))
      } else {
        viewStore.send(.ingredientRowTapped(ingredient))
      }
    } label: {
      HStack(alignment: .center, spacing: 12) {
        if viewStore.isEditMode {
          Image(systemName: viewStore.selectedIngredients.contains(ingredient.id) ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 24))
            .foregroundColor(viewStore.selectedIngredients.contains(ingredient.id) ? AppColor.primaryBlue500 : AppColor.grayscale400)
        }
        
        Text(ingredient.name)
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        
        Spacer()
        
        HStack(spacing: 8) {
          HStack(spacing: 4) {
            Text(ingredient.amount)
            Text(ingredient.price)
          }

          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
            .frame(width: 16, height: 16)
        }
        .frame(minHeight: 26)
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale600)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private func ingredientDetailSheet(viewStore: ViewStoreOf<MenuIngredientsFeature>) -> some View {
    VStack(spacing: 0) {
      Color.clear.frame(height: 40)

      if let ingredient = viewStore.selectedIngredient {
        VStack(alignment: .leading, spacing: 0) {
          Text(ingredient.name)
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)
            .padding(.bottom, 18)

          Text("사용량")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale900)

          HStack(spacing: 4) {
            TextField(
              "",
              text: viewStore.binding(
                get: \.selectedIngredientUsage,
                send: MenuIngredientsFeature.Action.ingredientDetailUsageChanged
              ),
              prompt: Text("제조시 사용되는 용량 입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale400)
            )
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)

            Text(viewStore.selectedIngredientUnit.title)
              .font(.pretendardSubtitle2)
              .foregroundColor(AppColor.grayscale900)
          }
          .padding(.top, 8)

          Rectangle()
            .fill(AppColor.grayscale300)
            .frame(height: 1)
            .padding(.top, 8)

          VStack(alignment: .leading, spacing: 12) {
            Text("재료 정보")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale800)

            infoRow(label: "단가", value: viewStore.selectedIngredientUnitPriceText)
            infoRow(label: "공급업체", value: viewStore.selectedIngredientSupplier)
          }
          .padding(12)
          .background(AppColor.grayscale200)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          .padding(.top, 14)

          Spacer(minLength: 12)

          BottomButton(
            title: "수정",
            style: isUpdateEnabled(viewStore) && !viewStore.isUpdatingIngredient ? .primary : .secondary
          ) {
            viewStore.send(.ingredientUpdateTapped)
          }
          .disabled(!isUpdateEnabled(viewStore) || viewStore.isUpdatingIngredient)
          .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
      }
    }
    .background(Color.white.ignoresSafeArea())
  }

  private func infoRow(label: String, value: String) -> some View {
    HStack(spacing: 8) {
      Text(label)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale500)

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(width: 1, height: 14)

      Text(value)
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale700)

      Spacer()
    }
  }

  private func isUpdateEnabled(_ viewStore: ViewStoreOf<MenuIngredientsFeature>) -> Bool {
    !viewStore.selectedIngredientUsage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

#Preview {
  NavigationStack {
    MenuIngredientsView(
      store: Store(
        initialState: MenuIngredientsFeature.State(
          menuId: 1,
          menuName: "바닐라 라떼",
          ingredients: [
            IngredientItem(name: "우유", amount: "30g", price: "800원"),
            IngredientItem(name: "설탕", amount: "30g", price: "800원"),
            IngredientItem(name: "시럽", amount: "30g", price: "800원"),
            IngredientItem(name: "초콜릿 가루", amount: "30g", price: "800원"),
            IngredientItem(name: "생크림", amount: "30g", price: "800원"),
            IngredientItem(name: "바닐라 엑스트랙", amount: "30g", price: "800원"),
            IngredientItem(name: "종이컵", amount: "30g", price: "800원"),
            IngredientItem(name: "컵 홀더", amount: "30g", price: "800원")
          ]
        )
      ) {
        MenuIngredientsFeature()
      }
    )
  }
}
