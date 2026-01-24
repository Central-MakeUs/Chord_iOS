import SwiftUI
import CoreModels
import DesignSystem

public struct AddIngredientSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var ingredientName: String = ""
  @State private var selectedTab: IngredientTab = .custom
  @State private var price: String = ""
  @State private var amount: String = ""
  @State private var selectedUnit: String = "g"
  @State private var supplier: String = ""
  
  let onAdd: (IngredientItem) -> Void
  
  public init(onAdd: @escaping (IngredientItem) -> Void) {
    self.onAdd = onAdd
  }
  
  enum IngredientTab {
    case custom
    case existing
    
    var title: String {
      switch self {
      case .custom: return "직접 등록"
      case .existing: return "운영 재료"
      }
    }
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      dragIndicator
      
      Text("재료 추가")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .padding(.top, 20)
        .padding(.bottom, 24)
      
      VStack(spacing: 24) {
        ingredientNameSection
        tabSelector
        
        if selectedTab == .custom {
          priceSection
          amountSection
          supplierSection
        }
      }
      .padding(.horizontal, 20)
      
      Spacer()
      
      BottomButton(
        title: "추가하기",
        style: .primary
      ) {
        addIngredient()
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 34)
    }
    .background(Color.white)
  }
  
  private var dragIndicator: some View {
    RoundedRectangle(cornerRadius: 2.5)
      .fill(AppColor.grayscale400)
      .frame(width: 40, height: 4)
      .padding(.top, 12)
  }
  
  private var ingredientNameSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("재료명")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
      
      TextField("", text: $ingredientName)
        .font(.pretendardTitle2)
        .foregroundColor(AppColor.grayscale900)
        .padding(.vertical, 4)
    }
  }
  
  private var tabSelector: some View {
    HStack(spacing: 8) {
      ForEach([IngredientTab.custom, IngredientTab.existing], id: \.title) { tab in
        Button(action: { selectedTab = tab }) {
          Text(tab.title)
            .font(.pretendardBody2)
            .foregroundColor(selectedTab == tab ? AppColor.primaryBlue500 : AppColor.grayscale600)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(selectedTab == tab ? AppColor.primaryBlue100 : AppColor.grayscale200)
            )
        }
        .buttonStyle(.plain)
      }
      Spacer()
    }
  }
  
  private var priceSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("가격")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
      
      HStack {
        TextField("", text: $price)
          .font(.pretendardTitle2)
          .foregroundColor(AppColor.grayscale900)
          .keyboardType(.numberPad)
        Text("원")
          .font(.pretendardTitle2)
          .foregroundColor(AppColor.grayscale900)
      }
      .padding(.vertical, 4)
    }
  }
  
  private var amountSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("사용량")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
      
      HStack {
        TextField("", text: $amount)
          .font(.pretendardTitle2)
          .foregroundColor(AppColor.grayscale900)
          .keyboardType(.numberPad)
        
        Menu {
          Button("g") { selectedUnit = "g" }
          Button("ml") { selectedUnit = "ml" }
          Button("개") { selectedUnit = "개" }
        } label: {
          HStack(spacing: 4) {
            Text(selectedUnit)
              .font(.pretendardTitle2)
              .foregroundColor(AppColor.grayscale900)
            Image(systemName: "chevron.down")
              .font(.system(size: 14))
              .foregroundColor(AppColor.grayscale500)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }
  
  private var supplierSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("공급업체")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)
      
      TextField("", text: $supplier)
        .font(.pretendardTitle2)
        .foregroundColor(AppColor.grayscale900)
        .padding(.vertical, 4)
    }
  }
  
  private func addIngredient() {
    guard !ingredientName.isEmpty,
          !price.isEmpty,
          !amount.isEmpty else {
      return
    }
    
    let ingredient = IngredientItem(
      name: ingredientName,
      amount: "\(amount)\(selectedUnit)",
      price: "\(price)원"
    )
    
    onAdd(ingredient)
    dismiss()
  }
}

#Preview {
  AddIngredientSheet { _ in }
}
