import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientEditSheetView: View {
  let store: StoreOf<IngredientEditSheetFeature>
  let onComplete: (String, String, IngredientUnit, String) -> Void

  @State private var isDropdownExpanded = false

  public init(
    store: StoreOf<IngredientEditSheetFeature>,
    onComplete: @escaping (String, String, IngredientUnit, String) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Color.clear.frame(height: 40)

        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Text(viewStore.name)
              .font(.pretendardTitle1)
              .foregroundColor(AppColor.grayscale900)

            HStack(spacing: 6) {
              categoryTab(
                text: "식재료",
                isSelected: viewStore.draftCategory == "식재료",
                action: { viewStore.send(.draftCategoryChanged("식재료")) }
              )
              categoryTab(
                text: "운영 재료",
                isSelected: viewStore.draftCategory == "운영 재료",
                action: { viewStore.send(.draftCategoryChanged("운영 재료")) }
              )
            }
          }

          VStack(alignment: .leading, spacing: 24) {
            UnderlinedField(
              title: "가격",
              text: viewStore.binding(
                get: \.draftPrice,
                send: IngredientEditSheetFeature.Action.draftPriceChanged
              ),
              trailingText: "원",
              keyboardType: .decimalPad,
              allowsComma: true
            )

            UnderlinedFieldWithDropdown(
              title: "사용량",
              text: viewStore.binding(
                get: \.draftUsage,
                send: IngredientEditSheetFeature.Action.draftUsageChanged
              ),
              selectedUnit: viewStore.draftUnit,
              isExpanded: $isDropdownExpanded,
              onUnitSelected: { viewStore.send(.unitSelected($0)) }
            )
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .zIndex(isDropdownExpanded ? 1 : 0)

        Spacer(minLength: 20)

        let isEnabled = viewStore.isSaveEnabled
        BottomButton(title: "수정", style: isEnabled ? .primary : .secondary) {
          guard isEnabled else { return }
          viewStore.send(.saveTapped)
          onComplete(viewStore.cleanedPrice, viewStore.cleanedUsage, viewStore.draftUnit, viewStore.draftCategory)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
    .presentationCornerRadius(24)
  }
}

private extension IngredientEditSheetView {
  func categoryTab(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(text)
        .font(.pretendardCaption2)
        .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale600)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(isSelected ? AppColor.primaryBlue200 : AppColor.grayscale200)
        .cornerRadius(8)
    }
    .buttonStyle(.plain)
  }
}

private struct UnderlinedField: View {
  let title: String
  @Binding var text: String
  let trailingText: String?
  let keyboardType: UIKeyboardType
  let allowsComma: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 6) {
        TextField(
          "",
          text: $text,
          prompt: Text("")
        )
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(keyboardType)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if let trailingText {
          Text(trailingText)
            .font(.pretendardSubtitle1)
            .foregroundColor(AppColor.grayscale900)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }
}

private struct UnderlinedFieldWithDropdown: View {
  let title: String
  @Binding var text: String
  let selectedUnit: IngredientUnit
  @Binding var isExpanded: Bool
  let onUnitSelected: (IngredientUnit) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 6) {
        TextField(
          "",
          text: $text,
          prompt: Text("")
        )
        .font(.pretendardSubtitle1)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.decimalPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        Button {
          isExpanded.toggle()
        } label: {
          HStack(spacing: 4) {
            Text(selectedUnit.title)
              .font(.pretendardSubtitle1)
              .foregroundColor(AppColor.grayscale900)
            Image(systemName: "chevron.down")
              .font(.system(size: 12))
              .foregroundColor(AppColor.grayscale900)
              .rotationEffect(.degrees(isExpanded ? 180 : 0))
          }
        }
        .buttonStyle(.plain)
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
    .overlay(alignment: .topTrailing) {
      if isExpanded {
        VStack(spacing: 0) {
          ForEach(Array(IngredientUnit.allCases.enumerated()), id: \.element) { index, unit in
            Button {
              onUnitSelected(unit)
              isExpanded = false
            } label: {
              HStack {
                Text(unit.title)
                  .font(.pretendardSubtitle2)
                  .foregroundColor(AppColor.grayscale900)
              }
              .frame(width: 22, height: 29)
              .padding(.leading, 35)
              .padding(.trailing, 20)
              .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            if index < IngredientUnit.allCases.count - 1 {
              Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
            }
          }
        }
        .background(AppColor.grayscale200)
        .cornerRadius(8)
        .shadow(color: Color(red: 0.18, green: 0.18, blue: 0.22).opacity(0.06), radius: 5, x: 0, y: 0)
        .frame(maxWidth: 78)
        .offset(y: 52)
      }
    }
    .zIndex(isExpanded ? 1000 : 0)
  }
}

#Preview {
  IngredientEditSheetView(
    store: Store(
      initialState: IngredientEditSheetFeature.State(
        name: "원두",
        draftCategory: "식재료",
        draftPrice: "5,000",
        draftUsage: "100",
        draftUnit: .g,
        initialCategory: "식재료",
        initialPrice: "5,000",
        initialUsage: "100",
        initialUnit: .g
      )
    ) {
      IngredientEditSheetFeature()
    },
    onComplete: { _, _, _, _ in }
  )
  .environment(\.colorScheme, .light)
}
