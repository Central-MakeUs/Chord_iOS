import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct IngredientSearchView: View {
  let store: StoreOf<IngredientSearchFeature>
  @Environment(\.dismiss) private var dismiss
  
  public init(store: StoreOf<IngredientSearchFeature>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        searchBar(viewStore: viewStore)
        
        if viewStore.searchText.isEmpty {
          VStack(alignment: .leading, spacing: 16) {
            Text("최근 검색")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)
              .padding(.horizontal, 20)
              .padding(.top, 20)
            
            VStack(spacing: 0) {
              ForEach(viewStore.recentSearches, id: \.self) { keyword in
                recentSearchRow(keyword: keyword, viewStore: viewStore)
              }
            }
          }
        } else {
          VStack(spacing: 12) {
            ForEach(viewStore.searchResults, id: \.self) { ingredientName in
              searchResultCell(name: ingredientName)
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
        }
        
        Spacer()
      }
      .background(AppColor.grayscale100.ignoresSafeArea())
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
    }
  }
  
  private func searchBar(viewStore: ViewStoreOf<IngredientSearchFeature>) -> some View {
    HStack(spacing: 12) {
      HStack(spacing: 8) {
        Image.searchIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale500)
          .frame(width: 16, height: 16)
        
        TextField(
          "",
          text: viewStore.binding(
            get: \.searchText,
            send: IngredientSearchFeature.Action.searchTextChanged
          ),
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
      .clipShape(RoundedRectangle(cornerRadius: 8))
      
      Button(action: { dismiss() }) {
        Text("취소")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(Color.white)
  }
  
  private func recentSearchRow(keyword: String, viewStore: ViewStoreOf<IngredientSearchFeature>) -> some View {
    Button(action: {
      viewStore.send(.recentSearchTapped(keyword))
    }) {
      HStack {
        Text(keyword)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        
        Spacer()
        
        Button(action: {
          viewStore.send(.removeRecentSearch(keyword))
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppColor.grayscale600)
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(Color.white)
    }
    .buttonStyle(.plain)
  }
  
  private func searchResultCell(name: String) -> some View {
    Text(name)
      .font(.pretendardTitle2)
      .foregroundColor(AppColor.grayscale900)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
      .background(Color.white)
      .cornerRadius(16)
      .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
  }
}

#Preview {
  IngredientSearchView(
    store: Store(initialState: IngredientSearchFeature.State()) {
      IngredientSearchFeature()
    }
  )
}
