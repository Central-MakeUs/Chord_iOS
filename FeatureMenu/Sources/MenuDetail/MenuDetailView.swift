import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuDetailView: View {
  let store: StoreOf<MenuDetailFeature>
  @Environment(\.dismiss) private var dismiss

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
              Button {
                viewStore.send(.manageTapped)
              } label: {
                Image.meatballIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.grayscale700)
                  .frame(width: 24, height: 24)
              }
              .buttonStyle(.plain)
              .disabled(viewStore.isLoading)
              .opacity(viewStore.isLoading ? 0.4 : 1.0)
            }
          }
        )
        
        ScrollView {
          VStack(spacing: 0) {
            menuInfoCard(item: viewStore.item)
              .padding(.horizontal, 20)

            VStack(spacing: 16) {
              marginInfoCard(status: viewStore.item.status, item: viewStore.item)
                VStack(alignment: .leading, spacing: 8) {
                  recommendedPriceCard(price: viewStore.item.recommendedPrice)
                  recommendedPriceDescription()
                }
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
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.isDeleteConfirmPresented,
          send: { _ in MenuDetailFeature.Action.deleteCancelTapped }
        ),
        title: "메뉴를 삭제하시겠어요?",
        alertType: .twoButton,
        leftButtonTitle: "아니요",
        rightButtonTitle: "삭제하기",
        leftButtonAction: {
          viewStore.send(.deleteCancelTapped)
        },
        rightButtonAction: {
          viewStore.send(.deleteConfirmTapped)
        }
      )
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.isDeleteSuccessPresented,
          send: { _ in MenuDetailFeature.Action.deleteSuccessTapped }
        ),
        title: "메뉴가 삭제 됐어요",
        alertType: .oneButton,
        rightButtonTitle: "확인",
        rightButtonAction: {
          viewStore.send(.deleteSuccessTapped)
        }
      )
      .overlay {
        if viewStore.isDeleting {
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

            manageMenuOverlay(viewStore: viewStore)
              .frame(width: 76, height: 80)
              .padding(.top, 50)
              .padding(.trailing, 20)
          }
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
    }
  }

  private func manageMenuOverlay(viewStore: ViewStoreOf<MenuDetailFeature>) -> some View {
    VStack(spacing: 0) {
      Button {
        viewStore.send(.editTapped)
      } label: {
        Text("수정")
          .font(.pretendardBody3)
          .foregroundColor(AppColor.grayscale900)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(height: 40)
      .buttonStyle(.plain)

      Divider()
        .background(AppColor.grayscale200)

      Button {
        viewStore.send(.deleteTapped)
      } label: {
        Text("삭제")
          .font(.pretendardBody3)
          .foregroundColor(AppColor.semanticWarningText)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(height: 40)
      .buttonStyle(.plain)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
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

  private func recommendedPriceDescription() -> some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(alignment: .center, spacing: 4) {
        Image.infoOutlinedIcon
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .foregroundColor(AppColor.grayscale500)
          .frame(width: 10, height: 10)
          .clipped()

        Text("마진율은 재료비와 인건비를 기준으로 계산한 추정값이예요.")
          .font(.pretendardCaption4)
          .foregroundColor(AppColor.grayscale500)
      }

      Text("우리 가게의 효율을 알려드려요.")
        .font(.pretendardCaption4)
        .foregroundColor(AppColor.grayscale500)
        .padding(.leading, 14)
    }
    .padding(.horizontal, 4)
  }

  private func shouldShowRecommendedPrice(for status: MenuStatus) -> Bool {
    switch status {
    case .warning, .danger:
      return true
    case .safe, .normal:
      return false
    }
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

      Rectangle()
        .fill(AppColor.grayscale200)
        .frame(height: 1)
      
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
