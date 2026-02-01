import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuRegistrationStep1View: View {
  let store: StoreOf<MenuRegistrationFeature>

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(onBackTap: { viewStore.send(.backTapped) })

        HStack {
          stepIndicator
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        nameInputSection(viewStore: viewStore)
          .padding(.horizontal, 20)
          .padding(.top, 10)

        if viewStore.showSuggestions {
          suggestionList(viewStore: viewStore)
        } else {
          ScrollView {
            VStack(spacing: 0) {
              if viewStore.isTemplateApplied || !viewStore.menuName.isEmpty {
                filledContentSection(viewStore: viewStore)
              }
            }
          }
          
          VStack(spacing: 20) {
            if viewStore.isTemplateApplied {
              templateAppliedBanner
            }
            
            bottomButtons(viewStore: viewStore)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
        }
      }
      .background(Color.white.ignoresSafeArea())
      .sheet(
        isPresented: viewStore.binding(
          get: \.showTemplateSheet,
          send: MenuRegistrationFeature.Action.showTemplateSheetChanged
        )
      ) {
        TemplateApplySheet(
          menuName: viewStore.selectedTemplateName,
          onApply: { viewStore.send(.applyTemplateTapped) },
          onCancel: { viewStore.send(.cancelTemplateTapped) }
        )
        .presentationDetents([.height(280)])
        .presentationBackground(Color.white)
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
    }
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

  private func nameInputSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 24) {
      UnderlinedTextField(
        text: viewStore.binding(
          get: \.menuName,
          send: MenuRegistrationFeature.Action.menuNameChanged
        ),
        title: "메뉴명",
        placeholder: "예)아메리카노",
        titleColor: AppColor.grayscale900,
        trailingIcon: !viewStore.menuName.isEmpty ? Image.cancelRoundedIcon : nil,
        onTrailingTap: {
          viewStore.send(.clearMenuNameTapped)
        }
      )
      
      UnderlinedTextField(
        text: viewStore.binding(
          get: \.price,
          send: MenuRegistrationFeature.Action.priceChanged
        ),
        title: "가격",
        placeholder: "가격을 입력해주세요",
        keyboardType: .numberPad
      )
    }
  }

  private func filledContentSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Color(uiColor: .systemGray6)
        .frame(height: 8)
        .padding(.top, 24)
      
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 16) {
          Text("카테고리")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)

          VStack(alignment: .leading, spacing: 16) {
            categoryRadioButton(label: "음료", isSelected: viewStore.selectedCategory == "음료") {
              viewStore.send(.categorySelected("음료"))
            }
            categoryRadioButton(label: "디저트", isSelected: viewStore.selectedCategory == "디저트") {
              viewStore.send(.categorySelected("디저트"))
            }
            categoryRadioButton(label: "푸드", isSelected: viewStore.selectedCategory == "푸드") {
              viewStore.send(.categorySelected("푸드"))
            }
          }
        }
        .padding(.top, 24)

        HStack {
          Text("제조시간")
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
          Spacer()
          HStack(spacing: 4) {
            Text(viewStore.workTimeText)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale900)
            Image.chevronRightOutlineIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale500)
          }
        }
        .padding(16)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        .padding(.top, 8)
      }
      .padding(.horizontal, 20)
    }
  }
  
  private func categoryRadioButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        ZStack {
          Circle()
            .stroke(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale300, lineWidth: 1.5)
            .frame(width: 20, height: 20)
          
          if isSelected {
            Circle()
              .fill(AppColor.primaryBlue500)
              .frame(width: 10, height: 10)
          }
        }
        
        Text(label)
          .font(.pretendardBody2)
          .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale900)
      }
    }
    .buttonStyle(.plain)
  }
  
  private var templateAppliedBanner: some View {
    HStack(spacing: 8) {
      ZStack {
        Circle()
          .fill(AppColor.primaryBlue500)
          .frame(width: 20, height: 20)
        
        Image(systemName: "checkmark")
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.white)
      }
      
      Text("템플릿이 적용됐어요")
        .font(.pretendardBody2)
        .foregroundColor(.white)
      
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(AppColor.grayscale700)
    .cornerRadius(12)
  }

  private func suggestionList(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      Divider()

      ScrollView {
        VStack(spacing: 0) {
          if viewStore.searchResults.isEmpty {
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
            ForEach(viewStore.searchResults, id: \.templateId) { item in
              Button(action: {
                viewStore.send(.templateSelected(item))
              }) {
                HStack(spacing: 8) {
                  highlightedText(for: item.menuName, query: viewStore.menuName)
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

              if item.templateId != viewStore.searchResults.last?.templateId {
                Divider().padding(.horizontal, 20)
              }
            }
          }
        }
      }
    }
    .background(Color.white)
  }

  private func bottomButtons(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    HStack(spacing: 8) {
      BottomButton(
        title: "이전",
        style: .secondary
      ) {
        viewStore.send(.previousStepTapped)
      }

      BottomButton(
        title: "다음",
        style: .primary
      ) {
        viewStore.send(.nextStepTapped)
      }
    }
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
