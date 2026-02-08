import SwiftUI
import CoreModels
import DesignSystem
import DataLayer
import ComposableArchitecture

public struct AddIngredientSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var ingredientName: String = ""
  @State private var searchResults: [SearchMyIngredientsResponse] = []
  @State private var isSearching: Bool = false
  @State private var searchTask: Task<Void, Never>?
  
  @Dependency(\.ingredientRepository) var ingredientRepository
  
  let onAdd: (IngredientItem) -> Void
  
  public init(onAdd: @escaping (IngredientItem) -> Void) {
    self.onAdd = onAdd
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      SheetDragHandle()
      
      Text("재료 추가")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.top, 20)
        .padding(.bottom, 24)
      
      VStack(alignment: .leading, spacing: 16) {
        ingredientNameSection
        
        if !searchResults.isEmpty {
          searchResultsSection
        }
      }
      .padding(.horizontal, 20)
      
      Spacer()
      
      BottomButton(
        title: "추가하기",
        style: ingredientName.isEmpty ? .secondary : .primary
      ) {
        addCustomIngredient()
      }
      .disabled(ingredientName.isEmpty)
      .padding(.horizontal, 20)
      .padding(.bottom, 34)
    }
    .background(Color.white)
  }
  
  private var ingredientNameSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("재료명")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)
      
      TextField("", text: $ingredientName)
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .placeholder(when: ingredientName.isEmpty) {
          Text("템플릿 있는 재료")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale400)
        }
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(AppColor.grayscale300)
            .frame(height: 1)
        }
        .onChange(of: ingredientName) { _, newValue in
          performSearch(query: newValue)
        }
    }
  }
  
  private var searchResultsSection: some View {
    VStack(spacing: 0) {
      ForEach(searchResults, id: \.ingredientId) { result in
        searchResultRow(result: result)
      }
    }
  }
  
  private func searchResultRow(result: SearchMyIngredientsResponse) -> some View {
    HStack {
      Text(highlightedText(fullText: result.ingredientName, searchText: ingredientName))
      
      Spacer()
      
      Button {
        addExistingIngredient(result)
      } label: {
        Image.plusCircleBlueIcon
          .resizable()
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.plain)
    }
    .padding(.vertical, 12)
  }
  
  private func highlightedText(fullText: String, searchText: String) -> AttributedString {
    var attributedString = AttributedString(fullText)
    attributedString.foregroundColor = AppColor.grayscale900
    attributedString.font = .pretendardSubtitle2
    
    if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
      attributedString[range].foregroundColor = AppColor.primaryBlue500
    }
    
    return attributedString
  }
  
  private func performSearch(query: String) {
    searchTask?.cancel()
    
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      searchResults = []
      return
    }
    
    isSearching = true
    searchTask = Task {
      try? await Task.sleep(for: .milliseconds(300))
      
      guard !Task.isCancelled else { return }
      
      do {
        let results = try await ingredientRepository.searchIngredients(query)
        await MainActor.run {
          self.searchResults = results
          self.isSearching = false
        }
      } catch {
        await MainActor.run {
          self.searchResults = []
          self.isSearching = false
        }
      }
    }
  }
  
  private func addExistingIngredient(_ result: SearchMyIngredientsResponse) {
    let ingredient = IngredientItem(
      ingredientId: result.ingredientId,
      name: result.ingredientName,
      amount: "0g",
      price: "0원"
    )
    onAdd(ingredient)
    dismiss()
  }
  
  private func addCustomIngredient() {
    guard !ingredientName.isEmpty else { return }
    
    let ingredient = IngredientItem(
      name: ingredientName,
      amount: "0g",
      price: "0원"
    )
    onAdd(ingredient)
    dismiss()
  }
}

private extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {
    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}

#Preview {
  AddIngredientSheet { _ in }
}
