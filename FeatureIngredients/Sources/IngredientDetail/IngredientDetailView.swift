import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientDetailView: View {
  let store: StoreOf<IngredientDetailFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<IngredientDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(
          leading: {
            Button {
              viewStore.send(.backTapped)
              dismiss()
            } label: {
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
                viewStore.send(.favoriteTapped)
              } label: {
                if viewStore.item.isFavorite {
                  Image.starFilledIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                } else {
                  Image.starIcon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(AppColor.grayscale400)
                    .frame(width: 24, height: 24)
                }
              }
              .buttonStyle(.plain)
            }
          }
        )
        
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            titleSection(
              category: displayCategoryName(from: viewStore.item.category),
              name: viewStore.item.name,
              priceText: viewStore.priceText,
              usageText: viewStore.usageText,
              unit: viewStore.unit,
              supplierName: viewStore.supplierName,
              onTap: { viewStore.send(.editPresented(true)) },
              onSupplierTap: { viewStore.send(.supplierPresented(true)) }
            )
            usageSection(menus: viewStore.item.usedMenus)
            Rectangle()
              .fill(AppColor.grayscale200)
              .frame(height: 10)
              .padding(.horizontal, -20)
            historySection(viewStore: viewStore)
            Spacer(minLength: 24)
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
          .padding(.bottom, 24)
        }
        
        VStack(spacing: 0) {
          BottomButton(title: "재료 삭제", style: .tertiary) {
            viewStore.send(.deleteTapped)
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 34)
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
              draftCategory: displayCategoryName(from: viewStore.item.category),
              draftPrice: viewStore.priceText,
              draftUsage: viewStore.usageText,
              draftUnit: viewStore.unit,
              initialCategory: displayCategoryName(from: viewStore.item.category),
              initialPrice: viewStore.priceText,
              initialUsage: viewStore.usageText,
              initialUnit: viewStore.unit
            )
          ) {
            IngredientEditSheetFeature()
          },
          onComplete: { price, usage, unit, category in
            viewStore.send(
              .editCompleted(
                price: price,
                usage: usage,
                unit: unit,
                category: categoryCode(from: category)
              )
            )
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
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.showDeleteAlert,
          send: { _ in IngredientDetailFeature.Action.deleteAlertCancelled }
        ),
        title: "재료를 삭제하시겠어요?",
        alertType: .twoButton,
        rightButtonTitle: "삭제하기",
        leftButtonAction: {
          viewStore.send(.deleteAlertCancelled)
        },
        rightButtonAction: {
          viewStore.send(.deleteAlertConfirmed)
        }
      )
      .onChange(of: viewStore.isDeleted) { isDeleted in
        if isDeleted {
          dismiss()
        }
      }
      .onAppear {
        print("👀 IngredientDetailView onAppear triggered")
        viewStore.send(.onAppear)
      }
      .ignoresSafeArea(edges: .bottom)
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.showToast,
          send: { _ in .toastDismissed }
        ),
        message: "수정이 반영되었어요!"
      )
    }
  }

  private func displayCategoryName(from value: String) -> String {
    switch value {
    case "INGREDIENTS":
      return "식재료"
    case "MATERIALS":
      return "운영 재료"
    default:
      return value
    }
  }

  private func categoryCode(from value: String) -> String {
    switch value {
    case "식재료":
      return "INGREDIENTS"
    case "운영 재료":
      return "MATERIALS"
    default:
      return value
    }
  }

  private func titleSection(
    category: String,
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
        Text(category)
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
        
        Text(supplierName.isEmpty ? "미등록" : supplierName)
          .font(.pretendardBody2)
          .foregroundColor(supplierName.isEmpty ? AppColor.grayscale400 : AppColor.grayscale700)
        
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale400)
          .frame(width: 16, height: 16)
      }
    }
    .buttonStyle(.plain)
  }

  private func usageSection(menus: [UsedMenuInfo]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 0) {
        Text("사용중인 메뉴 ")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        Text("\(menus.count)")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.primaryBlue500)
      }
      
      if menus.isEmpty {
        Text("사용중인 메뉴가 없습니다.")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale500)
          .padding(.vertical, 12)
      } else {
        HStack(spacing: 8) {
          ForEach(Array(menus.prefix(3)), id: \.menuName) { menu in
            let unit = menu.unitCode.displayUnit
            UsageMenuCard(
              menuName: menu.menuName,
              amount: "\(Int(menu.amount))\(unit)"
            )
          }
        }
      }
    }
  }

  private func historySection(viewStore: ViewStoreOf<IngredientDetailFeature>) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("변동 이력")
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale900)

      if !viewStore.priceHistory.isEmpty {
        ZStack(alignment: .topLeading) {
          TimelineLine()
          VStack(spacing: 16) {
            ForEach(viewStore.priceHistory) { item in
              HistoryRow(item: item)
            }
          }
          .padding(.bottom, TimelineStyle.tailLength)
        }
      } else {
        Text("변동 이력이 없습니다.")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale500)
          .padding(.vertical, 20)
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

private struct HistoryRow: View {
  let item: PriceHistoryResponse
  
  var formattedDate: String {
    let datePart = item.changeDate.prefix(10) // "2026-02-03"
    let components = datePart.split(separator: "-")
    if components.count == 3 {
      let year = components[0].suffix(2)
      return "\(year).\(components[1]).\(components[2])"
    }
    return String(datePart)
  }
  
  var formattedPrice: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let price = formatter.string(from: NSNumber(value: item.unitPrice)) ?? "\(Int(item.unitPrice))"
    return "\(price)원/\(item.baseQuantity)\(item.unitCode)"
  }

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Circle()
        .strokeBorder(AppColor.grayscale300, lineWidth: 1)
        .background(Circle().fill(AppColor.grayscale100))
        .frame(width: TimelineStyle.circleSize, height: TimelineStyle.circleSize)

      VStack(alignment: .leading, spacing: 4) {
        Text(formattedDate)
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale500)
        Text(formattedPrice)
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

private extension String {
  var displayUnit: String {
    self
      .replacingOccurrences(of: "G", with: "g")
      .replacingOccurrences(of: "ML", with: "ml")
      .replacingOccurrences(of: "EA", with: "개")
  }
}
