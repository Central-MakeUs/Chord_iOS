import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import FeatureMenuRegistration

public struct MenuView: View {
    let store: StoreOf<MenuFeature>
    
    public init(store: StoreOf<MenuFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                AppColor.grayscale200
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    menuHeader(
                        count: viewStore.menuItems.count,
                        onAdd: { viewStore.send(.addMenuTapped) }
                    )
                    
                    MenuTabs(selected: viewStore.selectedCategory) { category in
                        viewStore.send(.selectedCategoryChanged(category))
                    }
                    
                    HStack(spacing: 8) {
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AppColor.primaryBlue600)
                                .frame(width: 8, height: 8)
                            Text("마진율")
                                .font(.pretendardCaption4)
                                .foregroundColor(AppColor.primaryBlue600)
                        }
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AppColor.grayscale500)
                                .frame(width: 8, height: 8)
                            Text("원가율")
                                .font(.pretendardCaption4)
                                .foregroundColor(AppColor.grayscale600)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            menuList(items: viewStore.menuItems)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private func menuHeader(count: Int, onAdd: @escaping () -> Void) -> some View {
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
            
            Button(action: onAdd) {
                Image.plusIcon
                    .renderingMode(.template)
                    .foregroundColor(AppColor.grayscale900)
                    .frame(width: 24, height: 24)
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 20)
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

private struct MenuTabs: View {
    let selected: MenuCategory
    let onSelect: (MenuCategory) -> Void
    private let tabCategories: [MenuCategory] = [.all, .beverage, .dessert, .food]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabCategories) { category in
                    Button(action: { onSelect(category) }) {
                        VStack(spacing: 8) {
                            Text(category.title)
                                .font(.pretendardSubtitle3)
                                .foregroundColor(selected == category ? AppColor.grayscale900 : AppColor.grayscale600)
                            
                            Rectangle()
                                .fill(selected == category ? AppColor.grayscale900 : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            
            Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
                .offset(y: -1)
        }
    }
}

struct MenuBadge: View {
    let status: MenuStatus
    
    var body: some View {
        MenuStatusBadge(status: status)
    }
}

private struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                Text(item.price)
                    .font(.pretendardBody2)
                    .foregroundColor(AppColor.grayscale600)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                MenuBadge(status: item.status)
                HStack(spacing: 0) {
                    
                    Text(item.costRate)
                        .font(.pretendardBody4)
                        .foregroundColor(AppColor.grayscale600)
                    Text(item.marginRate)
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.primaryBlue600)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(AppColor.grayscale100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
