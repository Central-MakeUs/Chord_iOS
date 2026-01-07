import SwiftUI

struct MenuPriceEditSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var price: String
  @State private var draftPrice: String

  init(price: Binding<String>) {
    _price = price
    _draftPrice = State(initialValue: price.wrappedValue)
  }

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 24) {
        Text("가격을 입력해주세요")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)

        PriceInputField(
          text: $draftPrice,
          placeholder: "가격 입력",
          height: 47,
          backgroundColor: .clear
        )
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      Spacer(minLength: 20)

      let isEnabled = !draftPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      BottomButton(
        title: "완료",
        style: isEnabled ? .primary : .secondary
      ) {
        guard isEnabled else { return }
        price = formattedPrice(draftPrice)
        dismiss()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }

  private func formattedPrice(_ value: String) -> String {
    let digits = value.filter { $0.isNumber }
    guard let number = Int64(digits), !digits.isEmpty else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? digits
  }
}

#Preview {
  MenuPriceEditSheetView(price: .constant("5,600"))
    .environment(\.colorScheme, .light)
}
