import SwiftUI
import DesignSystem

public struct MenuRegistrationStep2View: View {
  @Environment(\.dismiss) private var dismiss
  @State private var ingredientInput: String = ""
  @State private var showDetailSheet: Bool = false
  @State private var selectedIngredientName: String = ""
  @State private var addedIngredients: [Ingredient] = [
    Ingredient(name: "원두", amount: "30g", price: "800원"),
    Ingredient(name: "물", amount: "250ml", price: "150원"),
    Ingredient(name: "종이컵", amount: "1개", price: "100원"),
    Ingredient(name: "테이크아웃 홀더", amount: "1개", price: "150원")
  ]
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      topBar
      HStack {
        stepIndicator
        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)

      
      ScrollView {
        VStack(spacing: 32) {
    
          inputSection
          
          addedListSection
          
          templateListSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 40)
      }
      
      bottomButtons
    }
    .background(Color.white.ignoresSafeArea())
      .sheet(isPresented: $showDetailSheet) {
        IngredientDetailSheet(
          ingredientName: selectedIngredientName,
          onAdd: {
            showDetailSheet = false
            addedIngredients.append(Ingredient(name: selectedIngredientName, amount: "200g", price: "5000원"))
          },
          onCancel: {
            showDetailSheet = false
          }
        )
        .presentationDetents([.height(420)])
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
    }
  
  
  private var topBar: some View {
    HStack {
      Button(action: { dismiss() }) {
        Image.arrowLeftIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale900)
      }
      Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  private var stepIndicator: some View {
    HStack(spacing: 2) {
      Circle()
        .fill(AppColor.grayscale300)
        .overlay(
          Text("1")
            .font(.pretendardCaption2)
            .foregroundColor(.white)
        )
        .frame(width: 24, height: 24)
      
      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 2)
      
      Circle()
        .fill(AppColor.primaryBlue500)
        .frame(width: 24, height: 24)
        .overlay(
          Text("2")
            .font(.pretendardCaption2)
            .foregroundColor(.white)
        )
    }
    .frame(width: 70)
    .padding(.bottom, 20)
  }
  
  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      
      Text("재료명")
        .font(.pretendardCaption1)
      
      UnderlinedTextField(
        text: $ingredientInput,
        title: nil,
        placeholder: "추가할 재료명을 입력해주세요",
        placeholderColor: AppColor.grayscale500, accentColor: AppColor.grayscale500, trailingIcon: !ingredientInput.isEmpty ? Image.cancelRoundedIcon : nil,
        onTrailingTap: {
          ingredientInput = ""
        }
      )
    }
  }
  
  private var addedListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("재료 리스트")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale900)
        
        Spacer()
        
        Text("선택")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(AppColor.grayscale100)
          .cornerRadius(16)
        
      }
      
      VStack(spacing: 0) {
        ForEach(addedIngredients) { item in
          HStack(spacing: 8) {
            Text(item.name)
              .font(.pretendardSubtitle3)
              .foregroundColor(AppColor.grayscale900)
            
            Spacer()
            
            Text(item.amount)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale600)
            
            Text(item.price)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale600)
          }
          .padding(.vertical, 16)
          
          if item.id != addedIngredients.last?.id {
            Divider()
          }
        }
      }
    }
  }
  
  private var templateListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("템플릿 있는 재료")
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
      
      VStack(spacing: 0) {
        ForEach(["흑임자 토핑", "시럽", "우유", "얼음"], id: \.self) { item in
          Button(action: {
            selectedIngredientName = item
            showDetailSheet = true
          }) {
            HStack {
              Text(item)
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale900)
              
              Spacer()
              
              Image.plusIcon
                .renderingMode(.template)
                .foregroundColor(AppColor.grayscale400)
                .frame(width: 24, height: 24)
            }
            .padding(.vertical, 16)
          }
          
          Divider()
        }
      }
    }
  }
  
  private var bottomButtons: some View {
    HStack(spacing: 8) {
      BottomButton(
        title: "이전",
        style: .secondary
      ) {
      }
      
      BottomButton(
        title: "다음",
        style: .primary
      ) {
      }
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
  }
}

struct Ingredient: Identifiable {
  let id = UUID()
  let name: String
  let amount: String
  let price: String
}

#Preview {
  MenuRegistrationStep2View()
}
