import SwiftUI

struct IngredientEditSheetView: View {
  @Environment(\.dismiss) private var dismiss
  let name: String
  @Binding var price: String
  @Binding var usage: String
  @Binding var unit: IngredientUnit

  @State private var draftPrice: String
  @State private var draftUsage: String
  @State private var draftUnit: IngredientUnit

  private let initialPrice: String
  private let initialUsage: String
  private let initialUnit: IngredientUnit

  init(
    name: String,
    price: Binding<String>,
    usage: Binding<String>,
    unit: Binding<IngredientUnit>
  ) {
    self.name = name
    _price = price
    _usage = usage
    _unit = unit
    _draftPrice = State(initialValue: price.wrappedValue)
    _draftUsage = State(initialValue: usage.wrappedValue)
    _draftUnit = State(initialValue: unit.wrappedValue)
    initialPrice = price.wrappedValue
    initialUsage = usage.wrappedValue
    initialUnit = unit.wrappedValue
  }

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 20) {
        Text(name)
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)

        VStack(alignment: .leading, spacing: 12) {
          UnderlinedField(
            title: "단가",
            text: $draftPrice,
            trailingText: "원",
            keyboardType: .numberPad,
            allowsComma: true
          )

          UnderlinedField(
            title: "사용량",
            text: $draftUsage,
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
                  isSelected: draftUnit == unit
                ) {
                  draftUnit = unit
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

      BottomButton(title: "수정", style: isEnabled ? .primary : .secondary) {
        guard isEnabled else { return }
        price = formattedPrice(draftPrice)
        usage = draftUsage.filter { $0.isNumber }
        unit = draftUnit
        dismiss()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }

  private var isEnabled: Bool {
    let cleanedPrice = formattedPrice(draftPrice)
    let cleanedUsage = draftUsage.filter { $0.isNumber }
    let hasChanges = cleanedPrice != initialPrice ||
      cleanedUsage != initialUsage ||
      draftUnit != initialUnit
    return hasChanges && !cleanedPrice.isEmpty && !cleanedUsage.isEmpty
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
    name: "원두",
    price: .constant("5,000"),
    usage: .constant("100"),
    unit: .constant(.g)
  )
  .environment(\.colorScheme, .light)
}
