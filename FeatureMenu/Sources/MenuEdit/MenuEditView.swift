import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuEditView: View {
  let store: StoreOf<MenuEditFeature>
  @Environment(\.dismiss) private var dismiss

  private let categories: [MenuCategory] = [.beverage, .dessert, .food]

  public init(store: StoreOf<MenuEditFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        AppColor.grayscale100
          .ignoresSafeArea()

        VStack(spacing: 0) {
          NavigationTopBar(
            onBackTap: {
              viewStore.send(.backTapped)
              dismiss()
            },
            title: ""
          )
          
          VStack(alignment: .leading, spacing: 24) {
          
          menuNameRow(name: viewStore.menuName) {
            viewStore.send(.nameEditPresented(true))
          }
          
          sectionDivider
          
          priceSection(price: viewStore.menuPrice) {
            viewStore.send(.priceEditPresented(true))
          }
          
          sectionDivider
          
          prepareTimeSection(time: viewStore.prepareTime) {
            viewStore.send(.prepareTimeTapped)
          }
          sectionDivider

          
          categorySection(
            selectedCategory: viewStore.selectedCategory,
            onSelect: { viewStore.send(.categorySelected($0)) }
          )
          Spacer()
          BottomButton(title: "메뉴 삭제", style: .tertiary) {
            viewStore.send(.deleteTapped)
          }
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
          get: \.isNameEditPresented,
          send: MenuEditFeature.Action.nameEditPresented
        )
      ) {
        MenuNameEditSheetView(
          store: Store(
            initialState: MenuNameEditSheetFeature.State(draftName: viewStore.menuName)
          ) {
            MenuNameEditSheetFeature()
          },
          onComplete: { viewStore.send(.menuNameUpdated($0)) }
        )
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isPriceEditPresented,
          send: MenuEditFeature.Action.priceEditPresented
        )
      ) {
        MenuPriceEditSheetView(
          store: Store(
            initialState: MenuPriceEditSheetFeature.State(draftPrice: viewStore.menuPrice)
          ) {
            MenuPriceEditSheetFeature()
          },
          onComplete: { viewStore.send(.menuPriceUpdated($0)) }
        )
        .presentationDetents([.height(296)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isPrepareTimePresented,
          send: MenuEditFeature.Action.prepareTimePresented
        )
      ) {
        PrepareTimeSheetView(
          store: Store(
            initialState: PrepareTimeSheetFeature.State(
              minutes: extractMinutes(from: viewStore.prepareTime),
              seconds: extractSeconds(from: viewStore.prepareTime)
            )
          ) {
            PrepareTimeSheetFeature()
          },
          onComplete: { minutes, seconds in
            viewStore.send(.prepareTimeUpdated(minutes: minutes, seconds: seconds))
          }
        )
        .presentationDetents([.height(357)])
        .presentationDragIndicator(.hidden)
        .modifier(SheetCornerRadiusModifier(radius: 24))
      }
    }
  }

  private func menuNameRow(name: String, onTap: @escaping () -> Void) -> some View {
    HStack(spacing: 6) {
      Text(name)
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
      Button(action: onTap) {
        Image.pencleIcon
          .foregroundColor(AppColor.grayscale600)
          .frame(width: 16, height: 16)
      }
      .buttonStyle(.plain)
      Spacer()
    }
  }

  private func priceSection(price: String, onTap: @escaping () -> Void) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("가격")
        .frame(height: 23)
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale700)

      valueRow(value: "\(price)원", onTap: onTap)

    }
  }

  private func prepareTimeSection(time: String, onTap: @escaping () -> Void) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("제조시간")
        .frame(height: 23)
        .font(.pretendardSubtitle3)
        .foregroundColor(AppColor.grayscale700)

      valueRow(value: time, onTap: onTap)

    }
  }

  private func valueRow(value: String, onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text(value)
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale900)
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale700)
        Spacer()
      }
    }
    .frame(height: 26)
    .buttonStyle(.plain)
  }

  private func categorySection(
    selectedCategory: MenuCategory,
    onSelect: @escaping (MenuCategory) -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("카테고리")
        .frame(height: 26)
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale700)

      VStack(alignment: .leading, spacing: 12) {
        ForEach(categories, id: \.self) { category in
          Button(action: { onSelect(category) }) {
            HStack(spacing: 8) {
              RadioIndicator(isSelected: selectedCategory == category)
              Text(category.title)
                .font(.pretendardSubtitle2)
                .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale900)
              Spacer()
            }
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private var sectionDivider: some View {
    Divider()
      .background(AppColor.grayscale300)
  }
  
  private func extractMinutes(from time: String) -> Int {
    let components = time.components(separatedBy: "분")
    guard let first = components.first,
          let minutes = Int(first.trimmingCharacters(in: .whitespaces)) else {
      return 0
    }
    return minutes
  }
  
  private func extractSeconds(from time: String) -> Int {
    let components = time.components(separatedBy: "분")
    guard components.count > 1 else { return 0 }
    let secondsPart = components[1].replacingOccurrences(of: "초", with: "")
    guard let seconds = Int(secondsPart.trimmingCharacters(in: .whitespaces)) else {
      return 0
    }
    return seconds
  }
}

private struct RadioIndicator: View {
  let isSelected: Bool

  var body: some View {
    if isSelected {
      Image.radioIcon
        .frame(width: 24, height: 24)
    } else {
      Image.radioUnselectedIcon
        .frame(width: 24, height: 24)
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
  MenuEditView(
    store: Store(
      initialState: MenuEditFeature.State(
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
    ) {
      MenuEditFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
