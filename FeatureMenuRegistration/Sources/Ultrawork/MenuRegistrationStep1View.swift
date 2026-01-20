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
  
  private let allMenuTemplates = [
    "흑임자라떼", "흑임자스콘", "흑임자케이크", "흑임자우유",
    "아메리카노", "아이스티", "에스프레소", "카푸치노",
    "카페라떼", "바닐라라떼", "카라멜마키아또", "녹차라떼"
  ]
  
  private var filteredTemplates: [String] {
    if menuName.isEmpty {
      return []
    }
    return allMenuTemplates.filter { $0.hasPrefix(menuName) }
  }
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 0) {
      NavigationTopBar(onBackTap: { dismiss() })
      
      HStack {
        stepIndicator
        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 24)
      
      nameInputSection
        .padding(.horizontal, 20)
        .padding(.top, 10)
      
      if showSuggestions {
        suggestionList
      } else {
        ScrollView {
          VStack(spacing: 24) {
            if isTemplateApplied || !menuName.isEmpty {
              filledContentSection
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 10)
        }
        
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
  
  private var stepIndicator: some View {
    HStack(spacing: 2) {
        Circle()
          .fill(AppColor.primaryBlue500)
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
          .fill(AppColor.grayscale300)
          .frame(width: 24, height: 24)
          .overlay(
            Text("2")
              .font(.pretendardCaption2)
          .foregroundColor(.white)
        )
    }
    .frame(width: 70)
  }
  
  private var nameInputSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      //TODO: 이거 피그마랑 다름
//      if menuName.isEmpty {
//        Text("등록하실 메뉴명을 입력해주세요")
//          .font(.pretendardCaption2)
//          .foregroundColor(AppColor.primaryBlue500)
//          .padding(.horizontal, 12)
//          .padding(.vertical, 8)
//          .background(AppColor.primaryBlue100)
//          .cornerRadius(8)
//          .padding(.bottom, -4)
//      }
//      
      UnderlinedTextField(
        text: $menuName,
        title: "메뉴명",
        placeholder: "예)아메리카노",
        titleColor: AppColor.grayscale900,
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
    VStack(spacing: 0) {
      Divider()
      
      ScrollView {
        VStack(spacing: 0) {
          if filteredTemplates.isEmpty {
            HStack {
              Image.searchIcon
                .renderingMode(.template)
                .foregroundColor(AppColor.grayscale400)
              Text("검색 결과가 없습니다")
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale500)
              Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
          } else {
            ForEach(filteredTemplates, id: \.self) { item in
              Button(action: {
                menuName = item
                showSuggestions = false
                showTemplateSheet = true
              }) {
                HStack(spacing: 8) {
                  highlightedText(for: item, query: menuName)
                    .font(.pretendardBody2)
                  
                  Spacer()
                  
                  Image.plusCircleBlueIcon
                    .resizable()
                    .frame(width: 24, height: 24)
                }
                .frame(height: 60)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              
              if item != filteredTemplates.last {
                Divider().padding(.horizontal, 20)
              }
            }
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
  
  private func highlightedText(for text: String, query: String) -> Text {
    guard query.count > 0, text.hasPrefix(query) else {
      return Text(text).foregroundColor(AppColor.grayscale900)
    }
    
    let matchedPart = String(text.prefix(query.count))
    let remainingPart = String(text.dropFirst(query.count))
    
    return Text(matchedPart)
      .foregroundColor(AppColor.grayscale500)
      + Text(remainingPart)
      .foregroundColor(AppColor.grayscale900)
  }
}

#Preview {
  MenuRegistrationStep1View()
}
