import SwiftUI
import DesignSystem

public struct MenuRegistrationStep1View: View {
  @Environment(\.dismiss) private var dismiss
  @State private var menuName: String = ""
  @State private var price: String = ""
  @State private var selectedCategory: String = "음료"
  @State private var showSuggestions: Bool = false
  @State private var isTemplateApplied: Bool = false
  @State private var showTemplateSheet: Bool = false
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      topBar
      
      stepIndicator
      
      ScrollView {
        VStack(spacing: 24) {
          nameInputSection
          
          if isTemplateApplied || !menuName.isEmpty && !showSuggestions {
            filledContentSection
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
      }
      
      if showSuggestions {
        suggestionList
      } else {
        bottomButtons
      }
    }
    .background(Color.white.ignoresSafeArea())
    .sheet(isPresented: $showTemplateSheet) {
      TemplateApplySheet(
        onApply: {
          showTemplateSheet = false
          isTemplateApplied = true
          showSuggestions = false
          price = "6500"
        },
        onCancel: {
          showTemplateSheet = false
        }
      )
      .presentationDetents([.height(280)])
    }
    .onChange(of: menuName) { newValue in
      if !newValue.isEmpty && !isTemplateApplied {
        showSuggestions = true
      } else {
        showSuggestions = false
      }
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
      Text("메뉴 등록")
        .font(.pretendardSubTitle)
        .foregroundColor(AppColor.grayscale900)
      Spacer()
      Image.arrowLeftIcon.opacity(0)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
  
  private var stepIndicator: some View {
    HStack(spacing: 4) {
      Circle()
        .fill(AppColor.primaryBlue500)
        .frame(width: 20, height: 20)
        .overlay(
          Text("1")
            .font(.pretendardCaption2)
            .foregroundColor(.white)
        )
      
      Rectangle()
        .fill(AppColor.grayscale200)
        .frame(width: 40, height: 2)
      
      Circle()
        .fill(AppColor.grayscale300)
        .frame(width: 20, height: 20)
        .overlay(
          Text("2")
            .font(.pretendardCaption2)
            .foregroundColor(.white)
        )
    }
    .padding(.bottom, 20)
  }
  
  private var nameInputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      if menuName.isEmpty {
        Text("등록하실 메뉴명을 입력해주세요")
          .font(.pretendardCaption2)
          .foregroundColor(AppColor.primaryBlue500)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(AppColor.primaryBlue100)
          .cornerRadius(8)
          .padding(.bottom, -4)
      }
      
      UnderlinedTextField(
        text: $menuName,
        title: "메뉴명",
        placeholder: "예)아메리카노",
        titleColor: AppColor.primaryBlue500,
        trailingIcon: !menuName.isEmpty ? Image.cancelRoundedIcon : nil,
        onTrailingTap: {
          menuName = ""
          isTemplateApplied = false
          showSuggestions = false
        }
      )
    }
  }
  
  private var filledContentSection: some View {
    VStack(alignment: .leading, spacing: 24) {
      
      if isTemplateApplied {
        HStack {
          Image.infoFilledIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.primaryBlue500)
          Text("템플릿이 적용됐어요")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.primaryBlue500)
          Spacer()
        }
        .padding(12)
        .background(AppColor.primaryBlue100)
        .cornerRadius(8)
      } else {
        HStack {
          Text("템플릿 없는 메뉴 입력")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale600)
          Spacer()
          Button(action: {}) {
            Text("직접입력")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale500)
              .underline()
          }
        }
      }
      
      UnderlinedTextField(
        text: $price,
        title: "가격",
        placeholder: "가격을 입력해주세요",
        keyboardType: .numberPad
      )
      
      VStack(alignment: .leading, spacing: 12) {
        Text("카테고리")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        
        HStack(spacing: 8) {
          ForEach(["음료", "디저트", "푸드"], id: \.self) { category in
            Button(action: { selectedCategory = category }) {
              Text(category)
                .font(.pretendardCaption1)
                .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale600)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                  RoundedRectangle(cornerRadius: 100)
                    .fill(selectedCategory == category ? AppColor.primaryBlue100 : AppColor.grayscale100)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 100)
                    .stroke(selectedCategory == category ? AppColor.primaryBlue500 : Color.clear, lineWidth: 1)
                )
            }
          }
        }
      }
      
      HStack {
        Text("제조시간")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Spacer()
        Text("1분 30초")
          .font(.pretendardBody2)
          .foregroundColor(AppColor.grayscale900)
        Image.chevronRightOutlineIcon
          .renderingMode(.template)
          .foregroundColor(AppColor.grayscale500)
      }
      .padding(.vertical, 12)
      .background(Color.white)
      .onTapGesture {
      }
    }
  }
  
  private var suggestionList: some View {
    VStack {
      Divider()
      ScrollView {
        VStack(spacing: 0) {
          ForEach(["흑임자라떼", "흑임자스콘", "흑임자케이크", "흑임자우유"], id: \.self) { item in
            Button(action: {
              menuName = item
              showSuggestions = false
              showTemplateSheet = true
            }) {
              HStack {
                Image.searchIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.grayscale500)
                Text(item)
                  .font(.pretendardBody2)
                  .foregroundColor(AppColor.grayscale900)
                Spacer()
              }
              .padding(.horizontal, 20)
              .padding(.vertical, 16)
            }
            Divider().padding(.horizontal, 20)
          }
        }
      }
    }
    .background(Color.white)
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

#Preview {
  MenuRegistrationStep1View()
}
