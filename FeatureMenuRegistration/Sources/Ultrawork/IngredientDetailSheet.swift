import SwiftUI
import UIKit
import DesignSystem

public struct IngredientDetailSheet: View {
  let ingredientName: String
  let onAdd: () -> Void
  let onCancel: () -> Void
  
  @State private var unitPrice: String = "5000"
  @State private var usage: String = "200"
  @State private var supplier: String = ""
  @State private var selectedUnit: String = "g"
  
  public init(
    ingredientName: String,
    onAdd: @escaping () -> Void,
    onCancel: @escaping () -> Void
  ) {
    self.ingredientName = ingredientName
    self.onAdd = onAdd
    self.onCancel = onCancel
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(ingredientName)
          .font(.pretendardSubtitle1)
          .foregroundColor(AppColor.grayscale900)
        Spacer()
        Button(action: onCancel) {
          Image.cancelRoundedIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
        }
      }
      .padding(.top, 24)
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
      
      VStack(spacing: 24) {
        UnderlinedTextField(
          text: $unitPrice,
          title: "단가",
          placeholder: "단가를 입력해주세요",
          keyboardType: .numberPad
        )
        
        HStack(spacing: 12) {
          ExpandedUnderlinedTextField(
            text: $usage,
            title: "사용량",
            placeholder: "0",
            keyboardType: .numberPad
          )
          
          VStack(alignment: .leading, spacing: 8) {
            Text("단위")
              .font(.pretendardCaption1)
              .foregroundColor(.clear)
            
            Menu {
              Button("g", action: { selectedUnit = "g" })
              Button("ml", action: { selectedUnit = "ml" })
              Button("개", action: { selectedUnit = "개" })
            } label: {
              HStack {
                Text(selectedUnit)
                  .font(.pretendardBody2)
                  .foregroundColor(AppColor.grayscale900)
                Spacer()
                Image.caretDownIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.grayscale500)
                  .frame(width: 16, height: 16)
              }
              .padding(.vertical, 12)
              .overlay(
                Rectangle()
                  .fill(AppColor.grayscale300)
                  .frame(height: 1),
                alignment: .bottom
              )
            }
          }
          .frame(width: 80)
        }
        
        UnderlinedTextField(
          text: $supplier,
          title: "공급업체",
          placeholder: "공급업체를 입력해주세요"
        )
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
      
      BottomButton(
        title: "추가하기",
        style: .primary
      ) {
        onAdd()
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .background(Color.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }
}

private struct ExpandedUnderlinedTextField: View {
  @Binding var text: String
  let title: String
  let placeholder: String
  let keyboardType: UIKeyboardType
  
  var body: some View {
    UnderlinedTextField(
      text: $text,
      title: title,
      placeholder: placeholder,
      keyboardType: keyboardType
    )
  }
}

#Preview {
  IngredientDetailSheet(ingredientName: "흑임자 토핑", onAdd: {}, onCancel: {})
}
