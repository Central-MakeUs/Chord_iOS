import SwiftUI

struct MenuEditView: View {
  let item: MenuItem
  @Environment(\.dismiss) private var dismiss
  @State private var menuName: String
  @State private var menuPrice: String
  @State private var selectedCategory: MenuCategory
  @State private var isNameEditPresented = false
  @State private var isPriceEditPresented = false

  private let categories: [MenuCategory] = [.beverage, .dessert]

  init(item: MenuItem) {
    self.item = item
    _menuName = State(initialValue: item.name)
    _menuPrice = State(initialValue: MenuEditView.formattedPrice(from: item.price))
    _selectedCategory = State(initialValue: item.category)
  }

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 24) {
        topBar
        menuNameRow
        priceSection
        categorySection
        Spacer()
        BottomButton(title: "메뉴 삭제", style: .tertiary) {}
      }
      .padding(.horizontal, 20)
      .padding(.top, 12)
      .padding(.bottom, 24)
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .sheet(isPresented: $isNameEditPresented) {
      MenuNameEditSheetView(name: $menuName)
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
    }
    .sheet(isPresented: $isPriceEditPresented) {
      MenuPriceEditSheetView(price: $menuPrice)
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
    }
  }

  private var topBar: some View {
    HStack(spacing: 8) {
      Button(action: { dismiss() }) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)

      Text("관리")
        .font(.pretendardCTA)
        .foregroundColor(AppColor.grayscale900)

      Spacer()
    }
  }

  private var menuNameRow: some View {
    HStack(spacing: 6) {
      Text(menuName)
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
      Button(action: { isNameEditPresented = true }) {
        Image.pencleIcon
          .foregroundColor(AppColor.grayscale600)
          .frame(width: 16, height: 16)
      }
      .buttonStyle(.plain)
      Spacer()
    }
  }

  private var priceSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("가격")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)

      Button(action: {
        isPriceEditPresented = true
      }) {
        HStack(spacing: 4) {
          Text("\(menuPrice)원")
            .font(.pretendardSubTitle)
            .foregroundColor(AppColor.grayscale900)
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale700)
          Spacer()

        }
      }
      .buttonStyle(.plain)

      Divider()
        .background(AppColor.grayscale300)
    }
  }

  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("카테고리")
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale700)

      VStack(spacing: 12) {
        ForEach(categories, id: \.self) { category in
          Button(action: { selectedCategory = category }) {
            HStack {
              Text(category.title)
                .font(.pretendardBody2)
                .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale900)
              Spacer()
              RadioIndicator(isSelected: selectedCategory == category)
            }
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
}

private struct RadioIndicator: View {
  let isSelected: Bool

  var body: some View {
    ZStack {
      Circle()
        .strokeBorder(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale300, lineWidth: 1.5)
        .frame(width: 20, height: 20)
      if isSelected {
        Circle()
          .fill(AppColor.primaryBlue500)
          .frame(width: 10, height: 10)
      }
    }
  }
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

private extension MenuEditView {
  static func formattedPrice(from value: String) -> String {
    let digits = value.filter { $0.isNumber }
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
  }
}

#Preview {
  MenuEditView(
    item: MenuItem(
      name: "돌체라떼",
      price: "5,600원",
      category: .beverage,
      status: .danger,
      costRate: "62.9%",
      marginRate: "23.2%",
      costAmount: "1,200원",
      contribution: "3,670원",
      ingredients: [],
      totalIngredientCost: "1,450원"
    )
  )
  .environment(\.colorScheme, .light)
}
