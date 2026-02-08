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
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
          
          Spacer()
          
          if viewStore.isEditMode {
            Button(action: {
              viewStore.send(.deleteTapped)
            }) {
              Text("삭제")
                .font(.pretendardCTA)
                .foregroundColor(viewStore.selectedIngredients.isEmpty ? AppColor.grayscale600 : AppColor.semanticWarningText)
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
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.showDeleteAlert,
          send: { _ in MenuIngredientsFeature.Action.deleteAlertCancelled }
        ),
        title: "메뉴를 삭제하시겠어요?",
        alertType: .twoButton,
        rightButtonTitle: "삭제하기",
        leftButtonAction: {
          viewStore.send(.deleteAlertCancelled)
        },
        rightButtonAction: {
          viewStore.send(.deleteAlertConfirmed)
        }
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
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.hidden)
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
                HStack(spacing: 4) {
                  Text("추가")
                    .font(.pretendardBody3)
                    .foregroundColor(AppColor.grayscale900)
                  Image.plusIcon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(AppColor.grayscale900)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
              }
              .buttonStyle(.plain)
              
              Divider()
                .background(AppColor.grayscale200)
              
              Button {
                viewStore.send(.deleteTapped)
              } label: {
                HStack(spacing: 4) {
                  Text("삭제")
                    .font(.pretendardBody3)
                    .foregroundColor(AppColor.grayscale900)
                  Image.trashIcon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(AppColor.grayscale900)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
              }
              .buttonStyle(.plain)
            }
            .frame(width: 100)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.top, 50)
            .padding(.trailing, 20)
          }
        }
      }
    }
  }
  
  private func ingredientRow(ingredient: IngredientItem, viewStore: ViewStoreOf<MenuIngredientsFeature>) -> some View {
    Button {
      if viewStore.isEditMode {
        viewStore.send(.ingredientToggled(ingredient.id))
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
        
        HStack(spacing: 4) {
          Text(ingredient.amount)
          Text(ingredient.price)
        }
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale600)
      }
      .frame(height: 26)
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
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
