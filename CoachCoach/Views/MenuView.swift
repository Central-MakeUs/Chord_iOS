import SwiftUI

struct MenuView: View {
  @State private var selectedCategory: MenuCategory = .all
  @EnvironmentObject private var menuRouter: MenuRouter
  
  var body: some View {
    NavigationStack(path: $menuRouter.path) {
      ZStack {
        AppColor.grayscale200
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            menuHeader
            MenuTabs(selected: selectedCategory) { category in
              selectedCategory = category
            }
            menuList
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }
      }
      .navigationDestination(for: MenuRoute.self) { route in
        switch route {
        case let .detail(item):
          MenuDetailView(item: item)
        case .add:
          BlankMenuView(title: "메뉴 추가")
        case let .edit(item):
          MenuDetailView(item: item)
        }
      }
    }
    .toolbar(.hidden, for: .navigationBar)
  }
  
  
  private var filteredMenuItems: [MenuItem] {
    switch selectedCategory {
    case .all:
      return allMenuItems
    case .beverage, .dessert:
      return allMenuItems.filter { $0.category == selectedCategory }
    }
  }
  
  private var allMenuItems: [MenuItem] {
    let ingredients = [
      IngredientItem(name: "에스프레소 샷", amount: "30ml", price: "450원"),
      IngredientItem(name: "우유", amount: "230ml", price: "750원"),
      IngredientItem(name: "종이컵", amount: "1개", price: "100원"),
      IngredientItem(name: "테이크아웃 홀더", amount: "1개", price: "150원")
    ]
    
    
    
    return [
      MenuItem(
        name: "돌체 라떼",
        price: "5,500원",
        category: .beverage,
        status: .danger,
        costRate: "33.4%",
        marginRate: "23.2%",
        costAmount: "1,840원",
        contribution: "3,660원",
        ingredients: ingredients,
        totalIngredientCost: "1,450원"
      ),
      MenuItem(
        name: "바닐라 라떼",
        price: "6,500원",
        category: .beverage,
        status: .warning,
        costRate: "24.4%",
        marginRate: "23.2%",
        costAmount: "1,590원",
        contribution: "4,910원",
        ingredients: ingredients,
        totalIngredientCost: "1,300원"
      ),
      MenuItem(
        name: "레몬티",
        price: "5,500원",
        category: .beverage,
        status: .safe,
        costRate: "33.4%",
        marginRate: "23.2%",
        costAmount: "1,840원",
        contribution: "3,660원",
        ingredients: ingredients,
        totalIngredientCost: "1,180원"
      ),
      MenuItem(
        name: "초콜릿 케익",
        price: "6,000원",
        category: .dessert,
        status: .safe,
        costRate: "30.0%",
        marginRate: "25.0%",
        costAmount: "1,800원",
        contribution: "4,200원",
        ingredients: ingredients,
        totalIngredientCost: "900원"
      ),
      MenuItem(
        name: "바나나 브레드",
        price: "4,200원",
        category: .dessert,
        status: .safe,
        costRate: "28.5%",
        marginRate: "20.0%",
        costAmount: "1,200원",
        contribution: "3,000원",
        ingredients: ingredients,
        totalIngredientCost: "1,600원"
      )
    ]
  }
  
  private var menuHeader: some View {
    HStack {
      HStack(spacing: 6) {
        Text("메뉴")
          .font(.pretendardTitle1)
          .foregroundStyle(AppColor.grayscale900)
        Text("\(filteredMenuItems.count)")
          .font(.pretendardTitle1)
          .foregroundStyle(AppColor.primaryBlue500)
      }
      
      Spacer()
      Button(action: {}) {
        Text("관리")
          .font(.pretendardCTA)
          .foregroundStyle(AppColor.grayscale700)
      }
    }
  }
  
  private var menuList: some View {
    VStack(spacing: 12) {
      ForEach(filteredMenuItems) { item in
        NavigationLink(value: MenuRoute.detail(item)) {
          MenuItemRow(item: item)
        }
        .buttonStyle(.plain)
      }
    }
  }

}

enum MenuCategory: String, CaseIterable, Identifiable {
  case all = "전체"
  case beverage = "음료"
  case dessert = "디저트"
  
  var id: String { rawValue }
  var title: String { rawValue }
}

struct MenuItem: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let price: String
  let category: MenuCategory
  let status: MenuStatus
  let costRate: String
  let marginRate: String
  let costAmount: String
  let contribution: String
  let ingredients: [IngredientItem]
  let totalIngredientCost: String
}

struct IngredientItem: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let amount: String
  let price: String
}

enum MenuStatus: CaseIterable {
  case safe
  case warning
  case danger
  
  var text: String {
    switch self {
    case .safe: return "안전"
    case .warning: return "주의"
    case .danger: return "위험"
    }
  }
  
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
  
  var body: some View {
    HStack(spacing: 8) {
      ForEach(MenuCategory.allCases) { category in
        Button(action: { onSelect(category) }) {
          Text(category.title)
            .font(.pretendardCTA)
            .foregroundStyle(selected == category ? AppColor.grayscale100 : AppColor.grayscale700)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
              Capsule()
                .fill(selected == category ? AppColor.primaryBlue500 : AppColor.grayscale100.opacity(0))
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
        .foregroundStyle(AppColor.grayscale900)
    }
  }
}

struct MenuBadge: View {
  let status: MenuStatus
  
  var body: some View {
    Text(status.text)
      .font(.pretendardCaption)
      .foregroundStyle(status.badgeTextColor)
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
      VStack(alignment: .leading, spacing: 6) {
        Text(item.name)
          .font(.pretendardSubTitle)
          .foregroundStyle(AppColor.grayscale900)
        HStack(spacing: 6) {
          Text(item.price)
            .foregroundStyle(AppColor.grayscale900)

          Text("원가율 \(item.costRate)")
            .foregroundStyle(AppColor.grayscale700)

        }
        .font(.pretendardBody1)
      }
      Spacer()
      VStack(alignment: .trailing, spacing: 6) {
        MenuBadge(status: item.status)
        Text(item.marginRate)
          .font(.pretendardSubTitle)
          .foregroundStyle(item.status.color)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 20)
    .background(AppColor.grayscale100)
    .clipShape(RoundedRectangle(cornerRadius: 8))
 
  }
}

#Preview {
  MenuView()
    .environmentObject(MenuRouter())
    .environment(\.colorScheme, .light)
}
