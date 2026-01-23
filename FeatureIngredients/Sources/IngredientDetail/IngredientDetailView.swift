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
      VStack(spacing: 0) {
        NavigationTopBar(
          onBackTap: {
            viewStore.send(.backTapped)
            dismiss()
          },
          title: "재료",
          trailing: .icon(Image.starIcon, action: {})
        )
        
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            titleSection(
              name: viewStore.item.name,
              priceText: viewStore.priceText,
              usageText: viewStore.usageText,
              unit: viewStore.unit,
              supplierName: viewStore.supplierName,
              onTap: { viewStore.send(.editPresented(true)) },
              onSupplierTap: { viewStore.send(.supplierPresented(true)) }
            )
            usageSection
            Rectangle()
              .fill(AppColor.grayscale200)
              .frame(height: 10)
              .padding(.horizontal, -20)
            historySection
            BottomButton(title: "재료 삭제", style: .tertiary) {}
              .padding(.top, 12)
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }
        .background(AppColor.grayscale100)
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
      }
    }
  }

  private func titleSection(
    name: String,
    priceText: String,
    usageText: String,
    unit: IngredientUnit,
    supplierName: String,
    onTap: @escaping () -> Void,
    onSupplierTap: @escaping () -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("식재료")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.grayscale600)
        
        Text(name)
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)
        
        Button(action: onTap) {
          HStack(spacing: 4) {
            Text("\(priceText)원 \(usageText)\(unit.title)")
              .font(.pretendardHeadline2)
              .foregroundColor(AppColor.grayscale900)
            Image.pencleIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale500)
              .frame(width: 20, height: 20)
          }
        }
        .buttonStyle(.plain)
      }
      supplierRow(supplierName: supplierName, onTap: onSupplierTap)
    }
    .padding(24)
    .background(Color.white)
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(AppColor.grayscale300, lineWidth: 1)
    )
  }

  private func supplierRow(supplierName: String, onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text("공급업체")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale600)
        
        Spacer()
        
        Text(supplierName.isEmpty ? "쿠팡" : supplierName)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale700)
        
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale400)
          .frame(width: 16, height: 16)
      }
    }
    .buttonStyle(.plain)
  }

  private var usageSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 0) {
        Text("사용중인 메뉴 ")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        Text("\(usedMenus.count)")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.primaryBlue500)
      }
      
      HStack(spacing: 8) {
        ForEach(usedMenus.prefix(3), id: \.self) { menu in
          UsageMenuCard(menuName: menu, amount: "100g")
        }
      }
    }
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

private struct UsageMenuCard: View {
  let menuName: String
  let amount: String

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(menuName)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale700)
        .lineLimit(2)
        .multilineTextAlignment(.leading)
      
      Spacer(minLength: 0)
      
      Text(amount)
        .font(.pretendardCaption3)
        .foregroundColor(AppColor.grayscale600)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 12)
    .frame(width: 106, height: 86, alignment: .topLeading)
    .background(AppColor.grayscale200)
    .cornerRadius(8)
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
