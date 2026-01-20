import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuView: View {
  let store: StoreOf<MenuFeature>

  public init(store: StoreOf<MenuFeature>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let filteredItems = filteredMenuItems(
        selected: viewStore.selectedCategory,
        items: viewStore.menuItems
      )

      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: MenuFeature.Action.pathChanged
        )
      ) {
        ZStack {
          AppColor.grayscale200
            .ignoresSafeArea()

          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              menuHeader(
                count: filteredItems.count,
                onManage: { viewStore.send(.isMenuManagePresentedChanged(true)) }
              )
              MenuTabs(selected: viewStore.selectedCategory) { category in
                viewStore.send(.selectedCategoryChanged(category))
              }
              menuList(items: filteredItems)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
          }
        }
        .navigationDestination(for: MenuRoute.self) { route in
          switch route {
          case let .detail(item):
            MenuDetailView(
              store: Store(initialState: MenuDetailFeature.State(item: item)) {
                MenuDetailFeature()
              }
            )
          case .add:
            BlankMenuView(title: "메뉴 추가")
          case let .edit(item):
            MenuEditView(
              store: Store(initialState: MenuEditFeature.State(item: item)) {
                MenuEditFeature()
              }
            )
          case let .ingredients(menuName, ingredients):
            MenuIngredientsView(menuName: menuName, ingredients: ingredients)
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .onAppear {
        viewStore.send(.onAppear)
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isMenuManagePresented,
          send: MenuFeature.Action.isMenuManagePresentedChanged
        )
      ) {
        MenuManageSheetView(
          store: Store(initialState: MenuManageSheetFeature.State()) {
            MenuManageSheetFeature()
          },
          onComplete: { viewStore.send(.isMenuManagePresentedChanged(false)) }
        )
        .presentationDetents([.height(357)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
    }
  }

  private func filteredMenuItems(
    selected: MenuCategory,
    items: [MenuItem]
  ) -> [MenuItem] {
    switch selected {
    case .all:
      return items
    case .beverage, .dessert, .food:
      return items.filter { $0.category == selected }
    }
  }

  private func menuHeader(count: Int, onManage: @escaping () -> Void) -> some View {
    HStack {
      HStack(spacing: 6) {
        Text("메뉴")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.grayscale900)
        Text("\(count)")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.primaryBlue500)
      }
      
      Spacer()
      
      Button(action: onManage) {
        Image.meatballIcon
          .frame(width: 24, height: 24)
      }
    }
  }
  
  private func menuList(items: [MenuItem]) -> some View {
    VStack(spacing: 12) {
      ForEach(items) { item in
        NavigationLink(value: MenuRoute.detail(item)) {
          MenuItemRow(item: item)
        }
        .buttonStyle(.plain)
      }
    }
  }

}

private extension MenuStatus {
  var color: Color {
    switch self {
    case .safe: return AppColor.semanticSafeText
    case .warning: return AppColor.semanticCautionText
    case .danger: return AppColor.semanticWarningText
    }
  }

  var badgeBackgroundColor: Color {
    color.opacity(0.15)
  }

  var badgeTextColor: Color {
    color
  }
}

private struct MenuTabs: View {
  let selected: MenuCategory
  let onSelect: (MenuCategory) -> Void
  private let tabCategories: [MenuCategory] = [.all, .beverage, .dessert]
  
  var body: some View {
    HStack(spacing: 8) {
      ForEach(tabCategories) { category in
        Button(action: { onSelect(category) }) {
          Text(category.title)
            .font(.pretendardCTA)
            .foregroundColor(selected == category ? AppColor.grayscale100 : AppColor.grayscale700)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(selected == category ? AppColor.grayscale700 : AppColor.grayscale100.opacity(0))
            )
        }
        .buttonStyle(.plain)
      }
    }
  }
}

private struct BlankMenuView: View {
  let title: String

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
      Text(title)
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)
    }
  }
}

struct MenuBadge: View {
  let status: MenuStatus
  
  var body: some View {
    Text(status.text)
      .font(.pretendardCaption)
      .foregroundColor(status.badgeTextColor)
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 4)
          .fill(status.badgeBackgroundColor)
      )
  }
}

private struct MenuItemRow: View {
  let item: MenuItem
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      VStack(alignment: .leading, spacing: 10) {
        Text(item.name)
          .font(.pretendardSubtitle1)
          .foregroundColor(AppColor.grayscale900)
        HStack(spacing: 6) {
          Text(item.price)
            .foregroundColor(AppColor.grayscale900)

          Text("원가율 \(item.costRate)")
            .foregroundColor(AppColor.grayscale600)

        }
        .font(.pretendardBody2)
      }
      Spacer()
      VStack(alignment: .trailing, spacing: 4) {
        MenuBadge(status: item.status)
        Text(item.marginRate)
          .font(.pretendardSubtitle2)
          .foregroundColor(item.status.color)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 20)
    .background(AppColor.grayscale100)
    .clipShape(RoundedRectangle(cornerRadius: 8))
 
  }
}

#Preview {
//  MenuView(
//    store: Store(
//      initialState: MenuFeature.State(
//        menuItems: [
//          MenuItem(
//            name: "아메리카노",
//            price: "4,500원",
//            category: .beverage,
//            status: .safe,
//            costRate: "22.2%",
//            marginRate: "30.5%",
//            costAmount: "1,000원",
//            contribution: "3,500원",
//            ingredients: [],
//            totalIngredientCost: "1,000원"
//          ),
//          MenuItem(
//            name: "카페라떼",
//            price: "5,000원",
//            category: .beverage,
//            status: .warning,
//            costRate: "30.0%",
//            marginRate: "25.0%",
//            costAmount: "1,500원",
//            contribution: "3,500원",
//            ingredients: [],
//            totalIngredientCost: "1,500원"
//          ),
//          MenuItem(
//            name: "카푸치노",
//            price: "5,500원",
//            category: .beverage,
//            status: .danger,
//            costRate: "35.5%",
//            marginRate: "20.0%",
//            costAmount: "1,950원",
//            contribution: "3,550원",
//            ingredients: [],
//            totalIngredientCost: "1,950원"
//          ),
//          MenuItem(
//            name: "초콜릿 케이크",
//            price: "6,000원",
//            category: .dessert,
//            status: .safe,
//            costRate: "25.0%",
//            marginRate: "28.0%",
//            costAmount: "1,500원",
//            contribution: "4,500원",
//            ingredients: [],
//            totalIngredientCost: "1,500원"
//          ),
//          MenuItem(
//            name: "치즈케이크",
//            price: "6,500원",
//            category: .dessert,
//            status: .warning,
//            costRate: "32.0%",
//            marginRate: "22.0%",
//            costAmount: "2,080원",
//            contribution: "4,420원",
//            ingredients: [],
//            totalIngredientCost: "2,080원"
//          )
//        ]
//      )
//    ) {
//      MenuFeature()
//    }
//  )
//  .environment(\.colorScheme, .light)
}

private struct SheetCornerRadiusModifier: ViewModifier {
  let radius: CGFloat

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 16.4, *) {
      content.presentationCornerRadius(radius)
    } else {
      content
    }
  }
}
