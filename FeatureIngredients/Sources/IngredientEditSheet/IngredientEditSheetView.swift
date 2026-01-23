import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientEditSheetView: View {
  let store: StoreOf<IngredientEditSheetFeature>
  let onComplete: (String, String, IngredientUnit) -> Void
  
  @State private var isDropdownExpanded = false

  public init(
    store: StoreOf<IngredientEditSheetFeature>,
    onComplete: @escaping (String, String, IngredientUnit) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Capsule()
          .fill(AppColor.grayscale300)
          .frame(width: 60, height: 6)
          .padding(.top, 12)

        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Text(viewStore.name)
              .font(.pretendardTitle1)
              .foregroundColor(AppColor.grayscale900)
            
            HStack(spacing: 6) {
              BadgeView(text: "식재료", style: .blue)
              BadgeView(text: "본사 제공", style: .gray)
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
              keyboardType: .numberPad,
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

        let cleanedPrice = formattedPrice(viewStore.draftPrice)
        let cleanedUsage = viewStore.draftUsage.filter { $0.isNumber }
        let hasChanges = cleanedPrice != viewStore.initialPrice ||
          cleanedUsage != viewStore.initialUsage ||
          viewStore.draftUnit != viewStore.initialUnit
        let isEnabled = hasChanges && !cleanedPrice.isEmpty && !cleanedUsage.isEmpty
        BottomButton(title: "수정", style: isEnabled ? .primary : .secondary) {
          guard isEnabled else { return }
          viewStore.send(.saveTapped)
          onComplete(cleanedPrice, cleanedUsage, viewStore.draftUnit)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
  }

  private func formattedPrice(_ value: String) -> String {
    let digits = value.filter { $0.isNumber }
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
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
        .onChange(of: text) { newValue in
          let filtered = newValue.filter { $0.isNumber || (allowsComma && $0 == ",") }
          if filtered != newValue {
            text = filtered
          }
        }

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
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onChange(of: text) { newValue in
          let filtered = newValue.filter { $0.isNumber }
          if filtered != newValue {
            text = filtered
          }
        }

        Button {
          isExpanded.toggle()
        } label: {
          HStack(spacing: 4) {
            Text(selectedUnit.title)
              .font(.pretendardSubtitle1)
              .foregroundColor(AppColor.grayscale900)
            Image(systemName: "chevron.down")
              .font(.system(size: 12))
              .foregroundColor(AppColor.grayscale500)
              .rotationEffect(.degrees(isExpanded ? 180 : 0))
          }
        }
        .buttonStyle(.plain)
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
    .overlay(alignment: .topLeading) {
      if isExpanded {
        VStack(spacing: 0) {
          ForEach(IngredientUnit.allCases, id: \.self) { unit in
            Button {
              onUnitSelected(unit)
              isExpanded = false
            } label: {
              HStack {
                Text(unit.title)
                  .font(.pretendardBody2)
                  .foregroundColor(unit == selectedUnit ? AppColor.primaryBlue500 : AppColor.grayscale900)
                Spacer()
                if unit == selectedUnit {
                  Image(systemName: "checkmark")
                    .font(.system(size: 14))
                    .foregroundColor(AppColor.primaryBlue500)
                }
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 12)
              .background(unit == selectedUnit ? AppColor.primaryBlue100 : Color.white)
            }
            .buttonStyle(.plain)
            
            if unit != IngredientUnit.allCases.last {
              Rectangle()
                .fill(AppColor.grayscale200)
                .frame(height: 1)
            }
          }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(AppColor.grayscale300, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .offset(y: 60)
      }
    }
    .zIndex(isExpanded ? 1000 : 0)
  }
}

private struct BadgeView: View {
  enum Style {
    case blue
    case gray
  }
  
  let text: String
  let style: Style
  
  var body: some View {
    Text(text)
      .font(.pretendardCaption2)
      .foregroundColor(style == .blue ? AppColor.primaryBlue500 : AppColor.grayscale600)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(style == .blue ? AppColor.primaryBlue100 : AppColor.grayscale200)
      .cornerRadius(4)
  }
}

#Preview {
  IngredientEditSheetView(
    store: Store(
      initialState: IngredientEditSheetFeature.State(
        name: "원두",
        draftPrice: "5,000",
        draftUsage: "100",
        draftUnit: .g,
        initialPrice: "5,000",
        initialUsage: "100",
        initialUnit: .g
      )
    ) {
      IngredientEditSheetFeature()
    },
    onComplete: { _, _, _ in }
  )
  .environment(\.colorScheme, .light)
}
