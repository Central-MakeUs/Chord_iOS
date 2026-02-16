import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuDetailView: View {
  let store: StoreOf<MenuDetailFeature>
  @Environment(\.dismiss) private var dismiss
  @State private var applyRecommendedPrice: Bool = false

  public init(store: StoreOf<MenuDetailFeature>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(
          leading: {
            Button(action: { dismiss() }) {
              Image.arrowLeftIcon
                .renderingMode(.template)
                .foregroundColor(AppColor.grayscale900)
                .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
          },
          trailing: {
            HStack {
              Spacer()
              NavigationLink(value: MenuRoute.edit(viewStore.item)) {
                Text("관리")
                  .font(.pretendardCTA)
                  .foregroundColor(AppColor.grayscale600)
              }
            }
          }
        )
        
        ScrollView {
          VStack(spacing: 0) {
            menuInfoCard(item: viewStore.item)
              .padding(.horizontal, 20)

            VStack(spacing: 16) {
              marginInfoCard(status: viewStore.item.status, item: viewStore.item)
              recommendedPriceCard(price: viewStore.item.recommendedPrice)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            Rectangle()
              .fill(AppColor.grayscale200)
              .frame(height: 10)
            
            ingredientsCard(item: viewStore.item)
              .padding(.horizontal, 20)
              .padding(.top, 24)
              .padding(.bottom, 16)
          }
        }
      }
      .background(AppColor.grayscale100.ignoresSafeArea())
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
    }
  }
  
  private func menuInfoCard(item: MenuItem) -> some View {
    VStack(alignment: .leading, spacing: 0) {

      
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 4) {
          Text(item.name)
            .font(.pretendardSubtitle4)
            .foregroundColor(AppColor.grayscale900)
          Text(formattedMenuPrice(item.price))
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)
        }
        
        Spacer()
        
        Rectangle()
          .fill(AppColor.grayscale300)
          .frame(width: 1, height: 40)
          .padding(.trailing, 16)
        
        VStack(alignment: .center, spacing: 4) {
          Text("제조시간")
            .font(.pretendardCaption4)
            .foregroundColor(AppColor.grayscale700)
          Text(item.workTimeText)
            .font(.pretendardCaption2)
            .foregroundColor(AppColor.grayscale700)
        }
      }
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.grayscale300, lineWidth: 1)
    )
  }
  
  private func marginInfoCard(status: MenuStatus, item: MenuItem) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 8) {
        Text("수익등급")
          .font(.pretendardCTA)
          .foregroundColor(AppColor.grayscale700)
        
        MenuBadge(status: status)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(statusMessage(for: status))
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale700)
        Text("가격 또는 원가 구조 점검을 권장드려요")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale700)
      }
      
      HStack(spacing: 0) {
        VStack(spacing: 6) {
          Text("마진율")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale700)
          Text(item.marginRate)
            .font(.pretendardBody1)
            .foregroundColor(statusColor(for: status))
        }
        .frame(maxWidth: .infinity)
        
        VStack(spacing: 6) {
          Text("원가율")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale700)
          Text(item.costRate)
            .font(.pretendardBody1)
            .foregroundColor(statusColor(for: status))
        }
        .frame(maxWidth: .infinity)
        
        VStack(spacing: 6) {
          Text("공헌이익")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale700)
          Text(item.contribution)
            .font(.pretendardBody1)
            .foregroundColor(AppColor.grayscale900)
        }
        .frame(maxWidth: .infinity)
      }
      .padding(.vertical, 12)
    }
    .padding(20)
    .background(
    LinearGradient(
    stops: [
    Gradient.Stop(color: AppColor.primaryBlue100, location: 0.00),
    Gradient.Stop(color: AppColor.grayscale100, location: 0.25),
    ],
    startPoint: UnitPoint(x: 0.47, y: -0.18),
    endPoint: UnitPoint(x: 0.47, y: 1.04)
    )
    )
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.primaryBlue200, lineWidth: 1)
    )
  }
  
  private func formattedRecommendedPrice(_ price: String) -> String {
    let cleaned = price.replacingOccurrences(of: "원", with: "")
                       .replacingOccurrences(of: ",", with: "")
    guard let number = Int(cleaned) else { return price }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return "\(formatter.string(from: NSNumber(value: number)) ?? "\(number)")원"
  }

  private func formattedMenuPrice(_ price: String) -> String {
    let cleaned = price.replacingOccurrences(of: "원", with: "")
      .replacingOccurrences(of: ",", with: "")
    guard let number = Int(cleaned) else { return price }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return "\(formatter.string(from: NSNumber(value: number)) ?? "\(number)")원"
  }

  private func recommendedPriceCard(price: String?) -> some View {
    HStack(spacing: 8) {
      Image.checkmarkIcon
        .frame(width: 12, height: 9)
      
      Text("권장가격 ")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      + Text(formattedRecommendedPrice(price ?? "- 원"))
        .font(.pretendardBody1)
        .foregroundColor(AppColor.primaryBlue500)
      
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(AppColor.grayscale200)
    .cornerRadius(16)
  }
  
  private func ingredientsCard(item: MenuItem) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      NavigationLink(value: MenuRoute.ingredients(menuId: item.apiId ?? 0, menuName: item.name, ingredients: item.ingredients)) {
        HStack(spacing: 4) {
          Text("재료 ")
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale900)
          + Text("\(item.ingredients.count)")
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.primaryBlue500)
          
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale600)
            .frame(width: 16, height: 16)
          
          Spacer()
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      
      VStack(spacing: 12) {
        ForEach(item.ingredients) { ingredient in
          ingredientRow(name: ingredient.name, amount: ingredient.amount, price: ingredient.price)
        }
      }
      
      HStack(spacing: 4) {
        Text("총")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale700)
        Text(item.totalIngredientCost)
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.top, 8)
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.grayscale300, lineWidth: 1)
    )
  }
  
  private func ingredientRow(name: String, amount: String, price: String) -> some View {
    HStack {
      Text("\(name) (\(amount))")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)
      Spacer()
      Text(price)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)
    }
  }
  
  private func statusMessage(for status: MenuStatus) -> String {
    switch status {
    case .danger:
      return "원가율이 너무 높은 편이에요!"
    case .warning:
      return "원가율이 조금 높은 편이에요!"
    case .normal:
      return "평균적인 마진율을 유지하고 있어요!"
    case .safe:
      return "적정한 마진율을 유지하고 있어요!"
    }
  }
  
  private func statusColor(for status: MenuStatus) -> Color {
    switch status {
    case .safe:
      return AppColor.semanticSafeText
    case .normal:
      return AppColor.primaryBlue500
    case .warning:
      return AppColor.semanticCautionText
    case .danger:
      return AppColor.semanticWarningText
    }
  }
}

#Preview {
  let ingredients = [
    IngredientItem(name: "원두", amount: "30g", price: "450원"),
    IngredientItem(name: "바닐라 시럽", amount: "10ml", price: "250원"),
    IngredientItem(name: "우유", amount: "230ml", price: "750원"),
    IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
    IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
  let item = MenuItem(
    name: "바닐라 라떼",
    price: "6,500원",
    category: .beverage,
    status: .danger,
    costRate: "62.9%",
    marginRate: "50.6%",
    costAmount: "1,840원",
    contribution: "3,670원",
    ingredients: ingredients,
    totalIngredientCost: "1,450원"
  )
  MenuDetailView(
    store: Store(initialState: MenuDetailFeature.State(item: item)) {
      MenuDetailFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
