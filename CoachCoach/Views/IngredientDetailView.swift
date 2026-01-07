import SwiftUI

struct IngredientDetailView: View {
  let item: InventoryIngredientItem
  @Environment(\.dismiss) private var dismiss
  @State private var priceText: String
  @State private var usageText: String
  @State private var unit: IngredientUnit
  @State private var supplierName: String = "쿠팡"
  @State private var isEditPresented = false
  @State private var isSupplierPresented = false

  private let usedMenus = ["아메리카노", "카페라떼", "돌체라떼", "아인슈페너"]
  private let historyItems = [
    IngredientHistoryItem(date: "25.11.12", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.11.09", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.10.11", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.09.08", price: "4,800원/100g")
  ]

  init(item: InventoryIngredientItem) {
    self.item = item
    let priceDigits = item.price.filter { $0.isNumber }
    let formattedPrice = IngredientDetailView.formattedNumber(from: priceDigits)
    let parsed = IngredientDetailView.parseAmount(item.amount)
    _priceText = State(initialValue: formattedPrice)
    _usageText = State(initialValue: parsed.value)
    _unit = State(initialValue: parsed.unit)
  }

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          topBar
          titleSection
          supplierRow
          usageSection
          Divider()
            .background(AppColor.grayscale200)
          historySection
          BottomButton(title: "재료 삭제", style: .tertiary) {}
            .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .sheet(isPresented: $isEditPresented) {
      IngredientEditSheetView(
        name: item.name,
        price: $priceText,
        usage: $usageText,
        unit: $unit
      )
      .presentationDetents([.height(420)])
      .presentationDragIndicator(.hidden)
      .modifier(SheetCornerRadiusModifier(radius: 24))
    }
    .sheet(isPresented: $isSupplierPresented) {
      IngredientSupplierSheetView(name: $supplierName)
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
    }
  }

  private var topBar: some View {
    HStack {
      Button(action: { dismiss() }) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
          .frame(width: 20, height: 20)
      }
      .buttonStyle(.plain)

      Spacer()

      Text("재료")
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)

      Spacer()

      Image.starIcon
        .renderingMode(.template)
        .foregroundColor(AppColor.grayscale600)
        .frame(width: 20, height: 20)
    }
  }

  private var titleSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(item.name)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      Button(action: {
        isEditPresented = true
      }) {
        HStack(spacing: 6) {
          Text("\(priceText)원 / \(usageText)\(unit.title)")
            .font(.pretendardDisplay2)
            .foregroundColor(AppColor.grayscale900)
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
        }
      }
      .buttonStyle(.plain)
    }
  }

  private var supplierRow: some View {
    Button(action: { isSupplierPresented = true }) {
      HStack(spacing: 4) {
        Text("공급업체")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale700)
        Spacer()

        HStack(spacing: 4) {
          Circle()
            .fill(AppColor.semanticWarningText)
            .frame(width: 18, height: 18)
          Text(supplierName)
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
        }
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale400)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(AppColor.grayscale200)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }

  private var usageSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 0) {
        Text("메뉴 ")
          .foregroundColor(AppColor.grayscale900)
        Text("\(usedMenus.count)")
          .foregroundColor(AppColor.primaryBlue500)
        Text("개에")
          .foregroundColor(AppColor.grayscale900)
      }
      Text("사용되고 있어요")
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 6) {
        ForEach(usedMenus, id: \.self) { menu in
          UsageTag(title: menu)
        }
      }
      .padding(.top, 8)
    }
    .font(.pretendardSubtitle3)
  }

  private var historySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("변동 이력")
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)

      ZStack(alignment: .topLeading) {
        TimelineLine()
        VStack(spacing: 16) {
          ForEach(historyItems, id: \.self) { item in
            HistoryRow(item: item)
          }
        }
        .padding(.bottom, TimelineStyle.tailLength)
      }
    }
  }
}

private struct UsageTag: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.pretendardCaption1)
      .foregroundColor(AppColor.grayscale700)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .strokeBorder(AppColor.grayscale300, lineWidth: 1)
      )
  }
}

private struct IngredientHistoryItem: Hashable {
  let date: String
  let price: String
}

private struct HistoryRow: View {
  let item: IngredientHistoryItem

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Circle()
        .strokeBorder(AppColor.grayscale300, lineWidth: 1)
        .background(Circle().fill(AppColor.grayscale100))
        .frame(width: TimelineStyle.circleSize, height: TimelineStyle.circleSize)

      VStack(alignment: .leading, spacing: 4) {
        Text(item.date)
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale500)
        Text(item.price)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
      }
    }
  }
}

private enum TimelineStyle {
  static let circleSize: CGFloat = 16
  static let lineWidth: CGFloat = 1
  static let tailLength: CGFloat = 12
}

private struct TimelineLine: View {
  var body: some View {
    GeometryReader { proxy in
      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(width: TimelineStyle.lineWidth, height: proxy.size.height)
        .offset(x: TimelineStyle.circleSize / 2 - TimelineStyle.lineWidth / 2)
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

private extension IngredientDetailView {
  static func formattedNumber(from value: String) -> String {
    guard let number = Int64(value) else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? value
  }

  static func parseAmount(_ value: String) -> (value: String, unit: IngredientUnit) {
    let digits = value.filter { $0.isNumber }
    let unitText = value.filter { !$0.isNumber }
    let unit = IngredientUnit.from(unitText)
    return (digits.isEmpty ? value : digits, unit)
  }
}

#Preview {
  IngredientDetailView(
    item: InventoryIngredientItem(
      name: "원두",
      amount: "100g",
      price: "5,000원"
    )
  )
  .environment(\.colorScheme, .light)
}
