import SwiftUI

struct IngredientSupplierSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var name: String
  @State private var draftName: String

  init(name: Binding<String>) {
    _name = name
    _draftName = State(initialValue: name.wrappedValue)
  }

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(AppColor.grayscale300)
        .frame(width: 60, height: 6)
        .padding(.top, 12)

      VStack(alignment: .leading, spacing: 24) {
        Text("공급업체명을 알려주세요")
          .font(.pretendardTitle1)
          .foregroundColor(AppColor.grayscale900)

        ClearableInputField(
          text: $draftName,
          placeholder: "공급업체명 입력",
          height: 47,
          backgroundColor: .clear
        )
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      Spacer(minLength: 20)

      let isEnabled = !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      BottomButton(title: "완료", style: isEnabled ? .primary : .secondary) {
        guard isEnabled else { return }
        name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
      }
      .disabled(!isEnabled)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(AppColor.grayscale100)
  }
}

#Preview {
  IngredientSupplierSheetView(name: .constant("쿠팡"))
    .environment(\.colorScheme, .light)
}
