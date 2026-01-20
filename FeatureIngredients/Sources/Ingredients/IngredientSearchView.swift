import SwiftUI
import DesignSystem

public struct IngredientSearchView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var searchText: String = ""
  @State private var recentSearches: [String] = ["레몬티", "딸기 가루"]
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      searchBar
      
      VStack(alignment: .leading, spacing: 16) {
        Text("최근 검색")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale700)
          .padding(.horizontal, 20)
          .padding(.top, 20)
        
        VStack(spacing: 0) {
          ForEach(recentSearches, id: \.self) { keyword in
            recentSearchRow(keyword: keyword)
          }
        }
      }
      
      Spacer()
    }
    .background(AppColor.grayscale100.ignoresSafeArea())
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
  }
  
  private var searchBar: some View {
    HStack(spacing: 12) {
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
  
  private func recentSearchRow(keyword: String) -> some View {
    HStack {
      Text(keyword)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      
      Spacer()
      
      Button(action: {
        recentSearches.removeAll { $0 == keyword }
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
}

#Preview {
  IngredientSearchView()
}
