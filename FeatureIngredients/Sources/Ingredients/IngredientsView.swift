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

      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: IngredientsFeature.Action.pathChanged
        )
      ) {
        ZStack {
          AppColor.grayscale200
            .ignoresSafeArea()

          VStack(spacing: 0) {
            header(totalCount: totalCount, viewStore: viewStore)
              .padding(.horizontal, 20)
              .padding(.vertical, 12)
            
            filterChips(
              selected: viewStore.selectedSearch,
              onSelect: { viewStore.send(.searchChipTapped($0)) }
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView {
              ingredientList(items: viewStore.filteredIngredients)
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
        .navigationDestination(for: IngredientsRoute.self) { route in
          switch route {
          case let .detail(item):
            IngredientDetailView(
              store: Store(initialState: IngredientDetailFeature.State(item: item)) {
                IngredientDetailFeature()
              }
            )
          case .add:
            EmptyView()
          case .search:
            IngredientSearchView(
              store: Store(initialState: IngredientSearchFeature.State()) {
                IngredientSearchFeature()
              }
            )
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
  
  private func header(totalCount: Int, viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
    HStack(spacing: 16) {
      HStack(spacing: 4) {
        Text("재료")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.grayscale900)
        Text("\(totalCount)")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.primaryBlue500)
      }
      Spacer()
      Button(action: { 
        viewStore.send(.searchButtonTapped)
      }) {
        Image.searchIcon
          .frame(width: 24, height: 24)
      }
      Button(action: {}) {
        Image.meatballIcon
          .frame(width: 24, height: 24)
      }
    }
  }
  
  private func filterChips(
    selected: String?,
    onSelect: @escaping (String) -> Void
  ) -> some View {
    HStack(spacing: 8) {
      ForEach(filterOptions, id: \.self) { keyword in
        Button(action: {
          onSelect(keyword)
        }) {
          HStack(spacing: 4) {
            Text(keyword)
              .font(.pretendardBody2)
              .foregroundColor(selected == keyword ? AppColor.primaryBlue500 : AppColor.grayscale600)
            
            if selected == keyword {
              Image(systemName: "xmark")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppColor.primaryBlue500)
            }
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(selected == keyword ? AppColor.primaryBlue200 : AppColor.grayscale300)
          )
        }
        .buttonStyle(.plain)
      }
      Spacer()
    }
  }
  private func ingredientList(items: [InventoryIngredientItem]) -> some View {
    VStack(spacing: 0) {
      ForEach(Array(items.enumerated()), id: \.element.id) { index, ingredient in
        NavigationLink(value: IngredientsRoute.detail(ingredient)) {
          IngredientRow(item: ingredient)
        }
        .buttonStyle(.plain)

        if index < items.count - 1 {
          Divider()
            .background(AppColor.grayscale200)
        }
      }
    }
  }
  private var filterOptions: [String] {
    ["출처찾기", "식재료", "운영 재료"]
  }
}

private struct IngredientRow: View {
  let item: InventoryIngredientItem

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Text(item.name)
        .font(.pretendardBody1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.leading, 20)
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(item.price)
          .font(.pretendardBody1)
          .foregroundColor(AppColor.primaryBlue500)
        Text("사용량 \(item.amount)")
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
