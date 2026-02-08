import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientsView: View {
  let store: StoreOf<IngredientsFeature>

  public init(store: StoreOf<IngredientsFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let totalCount = viewStore.filteredIngredients.count
      let selectedCount = viewStore.selectedForDeletion.count

      ZStack {
        AppColor.grayscale200
          .ignoresSafeArea()

        VStack(spacing: 0) {
          header(totalCount: totalCount, viewStore: viewStore)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
          
          filterChips(
            options: viewStore.filterOptions,
            selected: viewStore.selectedCategories,
            onSelect: { viewStore.send(.searchChipTapped($0)) }
          )
          .padding(.horizontal, 20)
          .padding(.top, 16)
          .padding(.bottom, 16)
          
          ScrollView {
            ingredientList(
              items: viewStore.filteredIngredients,
              isDeleteMode: viewStore.isDeleteMode,
              selectedIds: viewStore.selectedForDeletion,
              onSelect: { viewStore.send(.ingredientSelectedForDeletion($0)) }
            )
          }
          .background(
            Color.white
              .clipShape(
                UnevenRoundedRectangle(
                  topLeadingRadius: 24,
                  topTrailingRadius: 24
                )
              )
          )
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .toolbar(viewStore.isDeleteMode ? .hidden : .visible, for: .tabBar)
      .safeAreaInset(edge: .bottom) {
        if viewStore.isDeleteMode {
          deleteBottomBar(
            selectedCount: selectedCount,
            isDeleting: viewStore.isDeleting,
            onDelete: { viewStore.send(.deleteButtonTapped) }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .animation(.easeInOut(duration: 0.25), value: viewStore.isDeleteMode)
      .onAppear {
        if viewStore.hasLoadedOnce {
          viewStore.send(.refreshIngredients)
        } else {
          viewStore.send(.onAppear)
        }
      }
      .overlay(alignment: .topTrailing) {
        if viewStore.isManageMenuPresented && !viewStore.isDeleteMode {
          ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.001)
              .ignoresSafeArea()
              .onTapGesture {
                viewStore.send(.manageMenuDismissed)
              }
              
              manageMenuOverlay(viewStore: viewStore)
                  .frame(maxWidth: 78)
                  .padding(.top, 44)
                  .padding(.trailing, 20)
          }
        }
      }
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.showToast,
          send: IngredientsFeature.Action.showToastChanged
        ),
        message: viewStore.toastMessage,
        duration: 1.0
      )
    }
  }
  
  private func header(totalCount: Int, viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
    HStack(spacing: 16) {
      if viewStore.isDeleteMode {
        Button(action: { viewStore.send(.deleteCancelled) }) {
          Image.arrowLeftIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale900)
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
      }

      HStack(spacing: 4) {
        Text("재료")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.grayscale900)
        Text("\(totalCount)")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.primaryBlue500)
      }

      Spacer()

      if !viewStore.isDeleteMode {
        Button(action: {
          viewStore.send(.searchButtonTapped)
        }) {
          Image.searchIcon
            .frame(width: 24, height: 24)
        }
        Button(action: { viewStore.send(.manageMenuTapped) }) {
          Image.meatballIcon
            .frame(width: 24, height: 24)
        }
      }
    }
  }
  
  private func manageMenuOverlay(viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
    VStack(alignment: .center, spacing: 8) {
      Button(action: { viewStore.send(.addIngredientTapped) }) {
        HStack(spacing: 4) {
          Text("추가")
            .font(.pretendardBody3)
            .foregroundColor(AppColor.grayscale900)
          Image.plusIcon
            .renderingMode(.template)
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(AppColor.grayscale900)
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
      }
      .buttonStyle(.plain)
      
      Divider()
        .background(AppColor.grayscale200)
      
      Button(action: { viewStore.send(.deleteModeTapped) }) {
        HStack(spacing: 4) {
          Text("삭제")
            .font(.pretendardBody3)
            .foregroundColor(AppColor.semanticWarningText)
          Image.trashIcon
            .resizable()
            .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
      }
      .buttonStyle(.plain)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
  }
  
  private func filterChips(
    options: [String],
    selected: Set<String>,
    onSelect: @escaping (String) -> Void
  ) -> some View {
    HStack(spacing: 8) {
      ForEach(options, id: \.self) { keyword in
        let isSelected = selected.contains(keyword)
        Button(action: {
          onSelect(keyword)
        }) {
          HStack(spacing: 4) {
            Text(keyword)
              .font(.pretendardBody2)
              .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale600)
            
            if isSelected {
              Image(systemName: "xmark")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppColor.primaryBlue500)
            }
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(isSelected ? AppColor.primaryBlue200 : AppColor.grayscale300)
          )
        }
        .buttonStyle(.plain)
      }
      Spacer()
    }
  }
  private func ingredientList(
    items: [InventoryIngredientItem],
    isDeleteMode: Bool,
    selectedIds: Set<UUID>,
    onSelect: @escaping (UUID) -> Void
  ) -> some View {
    VStack(spacing: 0) {
      ForEach(Array(items.enumerated()), id: \.element.id) { index, ingredient in
        if isDeleteMode {
          Button(action: { onSelect(ingredient.id) }) {
            IngredientRow(
              item: ingredient,
              isDeleteMode: true,
              isSelected: selectedIds.contains(ingredient.id)
            )
          }
          .buttonStyle(.plain)
        } else {
          NavigationLink(value: IngredientsRoute.detail(ingredient)) {
            IngredientRow(item: ingredient, isDeleteMode: false, isSelected: false)
          }
          .buttonStyle(.plain)
        }

        if index < items.count - 1 {
          Divider()
            .background(AppColor.grayscale200)
        }
      }
    }
  }

  private func deleteBottomBar(
    selectedCount: Int,
    isDeleting: Bool,
    onDelete: @escaping () -> Void
  ) -> some View {
    let title = selectedCount > 0 ? "\(selectedCount)개 삭제" : "삭제"
    let isEnabled = selectedCount > 0 && !isDeleting
    
    return VStack(spacing: 0) {
      Divider()
        .background(AppColor.grayscale200)

      BottomButton(
        title: title,
        style: isEnabled ? .primary : .secondary
      ) {
        onDelete()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.top, 12)
      .padding(.bottom, 24)
      .background(Color.white)
    }
  }
}

private struct IngredientRow: View {
  let item: InventoryIngredientItem
  let isDeleteMode: Bool
  let isSelected: Bool
  
  private var displayAmount: String {
    let amount = item.amount
    return amount
      .replacingOccurrences(of: "G", with: "g")
      .replacingOccurrences(of: "ML", with: "ml")
      .replacingOccurrences(of: "EA", with: "개")
  }

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      if isDeleteMode {
        ZStack {
          Circle()
            .strokeBorder(
              isSelected ? AppColor.primaryBlue500 : AppColor.grayscale300,
              lineWidth: 2
            )
            .background(
              Circle()
                .fill(isSelected ? AppColor.primaryBlue500 : Color.clear)
            )
            .frame(width: 20, height: 20)

          Image(systemName: "checkmark")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(isSelected ? .white : AppColor.grayscale300)
        }
        .padding(.leading, 20)
      }

      Text(item.name)
        .font(.pretendardBody1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.leading, isDeleteMode ? 0 : 20)
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(item.price)
          .font(.pretendardBody1)
          .foregroundColor(AppColor.primaryBlue500)
        Text("사용량 \(displayAmount)")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale600)
      }
      .padding(.trailing, 20)
    }
    .padding(.vertical, 16)
  }
}

#Preview {
  IngredientsView(
    store: Store(initialState: IngredientsFeature.State()) {
      IngredientsFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
