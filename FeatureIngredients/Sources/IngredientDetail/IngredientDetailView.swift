import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientDetailView: View {
  let store: StoreOf<IngredientDetailFeature>
  @Environment(\.dismiss) private var dismiss
  private let usedMenus = ["아메리카노", "카페라떼", "돌체라떼", "아인슈페너"]
  private let historyItems = [
    IngredientHistoryItem(date: "25.11.12", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.11.09", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.10.11", price: "5,000원/100g"),
    IngredientHistoryItem(date: "25.09.08", price: "4,800원/100g")
  ]

  init(store: StoreOf<IngredientDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            topBar(onBack: {
              viewStore.send(.backTapped)
              dismiss()
            })
            titleSection(
              name: viewStore.item.name,
              priceText: viewStore.priceText,
              usageText: viewStore.usageText,
              unit: viewStore.unit,
              onTap: { viewStore.send(.editPresented(true)) }
            )
            supplierRow(
              supplierName: viewStore.supplierName,
              onTap: { viewStore.send(.supplierPresented(true)) }
            )
            Spacer().frame(height: 8)
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
      .sheet(
        isPresented: viewStore.binding(
          get: \.isEditPresented,
          send: IngredientDetailFeature.Action.editPresented
        )
      ) {
        IngredientEditSheetView(
          store: Store(
            initialState: IngredientEditSheetFeature.State(
              name: viewStore.item.name,
              draftPrice: viewStore.priceText,
              draftUsage: viewStore.usageText,
              draftUnit: viewStore.unit,
              initialPrice: viewStore.priceText,
              initialUsage: viewStore.usageText,
              initialUnit: viewStore.unit
            )
          ) {
            IngredientEditSheetFeature()
          },
          onComplete: { price, usage, unit in
            viewStore.send(.editCompleted(price: price, usage: usage, unit: unit))
          }
        )
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isSupplierPresented,
          send: IngredientDetailFeature.Action.supplierPresented
        )
      ) {
        IngredientSupplierSheetView(
          store: Store(initialState: IngredientSupplierSheetFeature.State(draftName: viewStore.supplierName)) {
            IngredientSupplierSheetFeature()
          },
          onComplete: { viewStore.send(.supplierCompleted($0)) }
        )
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
    }
  }

  private func topBar(onBack: @escaping () -> Void) -> some View {
    HStack {
      Button(action: onBack) {
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

  private func titleSection(
    name: String,
    priceText: String,
    usageText: String,
    unit: IngredientUnit,
    onTap: @escaping () -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(name)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
      Button(action: onTap) {
        HStack(spacing: 4) {
          Text("\(priceText)원 / \(usageText)\(unit.title)")
            .font(.pretendardDisplay2)
            .foregroundColor(AppColor.grayscale900)
          Image.chevronRightOutlineIcon
            .foregroundColor(AppColor.grayscale500)
        }
      }
      .buttonStyle(.plain)
    }
  }

  private func supplierRow(supplierName: String, onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text("공급업체")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale700)
        Spacer()

        HStack(spacing: 4) {
//          Circle()
//            .fill(AppColor.semanticWarningText)
//            .frame(width: 18, height: 18)
          Text(supplierName)
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale900)
        }
        Image.chevronRightOutlineIcon
          .foregroundColor(AppColor.grayscale400)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(AppColor.grayscale200)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
  }

  private var usageSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 0) {
        Text("사용중인 메뉴 ")
          .foregroundColor(AppColor.grayscale900)
        Text("\(usedMenus.count)")
          .foregroundColor(AppColor.primaryBlue500)
      }
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
        .font(.pretendardSubtitle3)
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
      .padding(.horizontal, 6)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .strokeBorder(AppColor.grayscale500, lineWidth: 1)
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
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale500)
        Text(item.price)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Spacer().frame(height: 16)
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

#Preview {
  IngredientDetailView(
    store: Store(
      initialState: IngredientDetailFeature.State(
        item: InventoryIngredientItem(
          name: "원두",
          amount: "100g",
          price: "5,000원"
        )
      )
    ) {
      IngredientDetailFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
