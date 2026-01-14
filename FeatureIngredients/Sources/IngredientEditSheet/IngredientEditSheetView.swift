import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientEditSheetView: View {
  let store: StoreOf<IngredientEditSheetFeature>
  let onComplete: (String, String, IngredientUnit) -> Void

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
          Text(viewStore.name)
            .font(.pretendardTitle1)
            .foregroundColor(AppColor.grayscale900)

          VStack(alignment: .leading, spacing: 12) {
            UnderlinedField(
              title: "단가",
              text: viewStore.binding(
                get: \.draftPrice,
                send: IngredientEditSheetFeature.Action.draftPriceChanged
              ),
              trailingText: "원",
              keyboardType: .numberPad,
              allowsComma: true
            )

            UnderlinedField(
              title: "사용량",
              text: viewStore.binding(
                get: \.draftUsage,
                send: IngredientEditSheetFeature.Action.draftUsageChanged
              ),
              trailingText: nil,
              keyboardType: .numberPad,
              allowsComma: false
            )

            VStack(alignment: .leading, spacing: 8) {
              Text("단위")
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale700)

              HStack(spacing: 8) {
                ForEach(IngredientUnit.allCases, id: \.self) { unit in
                  UnitChip(
                    title: unit.title,
                    isSelected: viewStore.draftUnit == unit
                  ) {
                    viewStore.send(.unitSelected(unit))
                  }
                  .frame(maxWidth: .infinity)
                }
              }
              .frame(maxWidth: .infinity)
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

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
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)

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

private struct UnitChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.pretendardBody2)
        .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale500)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(height: 40)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? AppColor.primaryBlue100 : AppColor.grayscale100)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale300, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
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
