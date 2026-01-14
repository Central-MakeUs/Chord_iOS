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
      let filtered = filteredIngredients(
        searchText: viewStore.searchText,
        items: mockIngredients
      )
      let totalCount = mockIngredients.count

      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: IngredientsFeature.Action.pathChanged
        )
      ) {
        ZStack {
          AppColor.grayscale100
            .ignoresSafeArea()

          ScrollView {
            VStack(alignment: .leading, spacing: 12) {
              header(totalCount: totalCount)
              searchBar(
                text: viewStore.binding(
                  get: \.searchText,
                  send: IngredientsFeature.Action.searchTextChanged
                )
              )
              filterChips(
                selected: viewStore.selectedSearch,
                onSelect: { viewStore.send(.searchChipTapped($0)) }
              )
              ingredientList(items: filtered)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
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
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
    }
  }
  
  private func header(totalCount: Int) -> some View {
    HStack {
      HStack(spacing: 6) {
        Text("재료")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)
        Text("\(totalCount)")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.primaryBlue500)
      }
      Spacer()
      Button(action: {}) {
        Text("추가 +")
          .font(.pretendardCTA)
          .foregroundColor(AppColor.grayscale700)
      }
      .buttonStyle(.plain)
    }
  }
  
  private func searchBar(text: Binding<String>) -> some View {
    HStack(spacing: 8) {
      Image.searchIcon
        .renderingMode(.template)
        .foregroundColor(AppColor.grayscale500)
        .frame(width: 16, height: 16)
      TextField(
        "",
        text: text,
        prompt: Text("재료명, 메뉴명으로 검색")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale500)
      )
      .font(.pretendardBody2)
      .foregroundColor(AppColor.grayscale900)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(AppColor.grayscale200)
    .clipShape(RoundedRectangle(cornerRadius: 14))
  }
  
  private func filterChips(
    selected: String,
    onSelect: @escaping (String) -> Void
  ) -> some View {
    HStack(spacing: 8) {
      ForEach(filterOptions, id: \.self) { keyword in
        Button(action: {
          onSelect(keyword)
        }) {
          Text(keyword)
            .font(.pretendardBody2)
            .foregroundColor(selected == keyword ? AppColor.primaryBlue500 : AppColor.grayscale700)
            .frame(height: 26)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
              Capsule()
                .stroke(
                  selected == keyword ? AppColor.primaryBlue500 : AppColor.grayscale600,
                  lineWidth: 1
                )
                .background(
                  Capsule()
                    .fill(selected == keyword ? AppColor.primaryBlue100 : AppColor.grayscale100)
                )
            )
        }
        .buttonStyle(.plain)
      }
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
  
  private func filteredIngredients(
    searchText: String,
    items: [InventoryIngredientItem]
  ) -> [InventoryIngredientItem] {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      return items.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
    return items
  }

  private var filterOptions: [String] {
    ["식재료", "운영 재료", "즐겨찾기"]
  }
  
  private var mockIngredients: [InventoryIngredientItem] {
    [
      InventoryIngredientItem(name: "우유", amount: "1500ml", price: "2,500원"),
      InventoryIngredientItem(name: "설탕", amount: "500g", price: "1,000원"),
      InventoryIngredientItem(name: "시럽", amount: "250ml", price: "3,500원"),
      InventoryIngredientItem(name: "초콜릿 가루", amount: "200g", price: "4,200원"),
      InventoryIngredientItem(name: "생크림", amount: "300g", price: "3,800원"),
      InventoryIngredientItem(name: "바닐라 엑스트랙", amount: "100ml", price: "6,000원"),
      InventoryIngredientItem(name: "종이컵", amount: "1개", price: "100원"),
      InventoryIngredientItem(name: "컵 홀더", amount: "1개", price: "150원"),
      InventoryIngredientItem(name: "시나몬 파우더", amount: "80g", price: "2,200원"),
      InventoryIngredientItem(name: "카라멜 시럽", amount: "200ml", price: "3,900원"),
      InventoryIngredientItem(name: "민트", amount: "30g", price: "1,300원")
    ]
  }
}

private struct IngredientRow: View {
  let item: InventoryIngredientItem

  var body: some View {
    HStack {
      Text(item.name)
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      Text("\(item.price)/\(item.amount)")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale700)
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
