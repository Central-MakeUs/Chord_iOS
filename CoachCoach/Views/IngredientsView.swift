import SwiftUI

struct IngredientsView: View {
  @EnvironmentObject private var inventoryRouter: InventoryRouter
  @State private var selectedSearch = "전체"
  @State private var searchText = ""

  var body: some View {
    NavigationStack(path: $inventoryRouter.path) {
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()
        
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            header
            searchBar
            filterChips
            ingredientList
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
  }
  
  private var header: some View {
    HStack {
      Text("재료")
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      Button(action: {}) {
        HStack(spacing: 4) {
          Text("추가")
            .font(.pretendardBody1)
          Image.plusIcon
            .renderingMode(.template)
            .frame(width: 12, height: 12)
        }
        .foregroundColor(AppColor.grayscale700)
      }
    }
  }
  
  private var searchBar: some View {
    HStack(spacing: 8) {
      Image.searchIcon
        .renderingMode(.template)
        .foregroundColor(AppColor.grayscale500)
        .frame(width: 16, height: 16)
      TextField(
        "",
        text: $searchText,
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
  
  private var filterChips: some View {
    HStack(spacing: 8) {
      ForEach(recentSearches, id: \.self) { keyword in
        Button(action: {
          selectedSearch = keyword
          searchText = keyword == "전체" ? "" : keyword
        }) {
          Text(keyword)
            .font(.pretendardCaption)
            .foregroundColor(selectedSearch == keyword ? AppColor.primaryBlue500 : AppColor.grayscale700)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
              Capsule()
                .stroke(
                  selectedSearch == keyword ? AppColor.primaryBlue500 : AppColor.grayscale500,
                  lineWidth: 1
                )
                .background(
                  Capsule()
                    .fill(selectedSearch == keyword ? AppColor.primaryBlue100 : AppColor.grayscale100)
                )
            )
        }
        .buttonStyle(.plain)
      }
    }
  }
  
  private var ingredientList: some View {
    VStack(spacing: 0) {
      ForEach(filteredIngredients) { ingredient in
        IngredientRow(item: ingredient)
        Divider()
          .background(AppColor.grayscale200)
      }
    }
  }
  
  private var filteredIngredients: [InventoryIngredientItem] {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      return mockIngredients.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
    guard selectedSearch != "전체" else { return mockIngredients }
    return mockIngredients.filter { $0.name.localizedCaseInsensitiveContains(selectedSearch) }
  }

  private var recentSearches: [String] {
    ["전체", "우유", "설탕", "시럽"]
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
      InventoryIngredientItem(name: "컵 홀더", amount: "1개", price: "150원")
    ]
  }
}

private struct IngredientRow: View {
  let item: InventoryIngredientItem
  
  var body: some View {
    HStack {
      Text(item.name)
        .font(.pretendardBody1)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      Text("\(item.price)/\(item.amount)")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)
    }
    .padding(.vertical, 10)
  }
}

private struct InventoryIngredientItem: Identifiable {
  let id = UUID()
  let name: String
  let amount: String
  let price: String
}

#Preview {
  IngredientsView()
    .environmentObject(InventoryRouter())
    .environment(\.colorScheme, .light)
}
