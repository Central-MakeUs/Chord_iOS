import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

public struct MenuRegistrationStep1View: View {
  let store: StoreOf<MenuRegistrationFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(onBackTap: {
          viewStore.send(.backTapped)
          dismiss()
        })

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
              if !viewStore.price.isEmpty {
                filledContentSection(viewStore: viewStore)
              }
            }
            .animation(.easeInOut(duration: 1), value: viewStore.price.isEmpty)
          }
          
          VStack(spacing: 20) {
            bottomButtons(viewStore: viewStore)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
        }
      }
      .background(Color.white.ignoresSafeArea())
      .contentShape(Rectangle())
      .simultaneousGesture(
        TapGesture().onEnded {
          dismissKeyboard()
        }
      )
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.showTemplateAppliedBanner,
          send: MenuRegistrationFeature.Action.showTemplateAppliedBannerChanged
        ),
        message: "템플릿이 적용됐어요",
        duration: 1.0
      )
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
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.white)
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.isTimePickerPresented,
          send: MenuRegistrationFeature.Action.showTimePickerChanged
        )
      ) {
        PrepareTimeSheetView(
          store: Store(
            initialState: PrepareTimeSheetFeature.State(
              minutes: viewStore.workTimeMinutes,
              seconds: viewStore.workTimeSeconds
            )
          ) {
            PrepareTimeSheetFeature()
          },
          onComplete: { minutes, seconds in
            viewStore.send(.workTimeUpdated(minutes: minutes, seconds: seconds))
            viewStore.send(.showTimePickerChanged(false))
          }
        )
        .presentationDetents([.height(360)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
    }
  }

  private func dismissKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
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
      
      if viewStore.menuName.isEmpty {
        HStack(spacing: 0) {
          Spacer(minLength: 0)
          SpeechBubbleBanner(text: "등록하실 메뉴명을 입력해주세요")
        }
        .padding(.top, -12)
        .transition(.opacity)
      }
      
      if viewStore.isTemplateApplied || !viewStore.menuName.isEmpty && !viewStore.showSuggestions {
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

        Button(action: {
          viewStore.send(.showTimePickerChanged(true))
        }) {
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
        .buttonStyle(.plain)
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
  


  private func suggestionList(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      Divider()

      ScrollView {
        VStack(spacing: 0) {
          if viewStore.searchResults.isEmpty {
            VStack(spacing: 8) {
              Text("찾으시는 메뉴가 없나요?")
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale500)
              
              Button(action: {
                viewStore.send(.directInputTapped)
              }) {
                Text("'\(viewStore.menuName)' 직접 입력")
                  .font(.pretendardBody2)
                  .foregroundColor(AppColor.primaryBlue500)
                  .underline()
              }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
          } else {
            ForEach(viewStore.searchResults, id: \.templateId) { item in
              Button(action: {
                viewStore.send(.templateSelected(item))
              }) {
                HStack(spacing: 8) {
                  highlightedText(fullText: item.menuName, searchText: viewStore.menuName)

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

            }
          }
        }
      }
    }
    .background(Color.white)
  }

  private func bottomButtons(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    let isNextEnabled = !viewStore.menuName
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .isEmpty

      return HStack(spacing: 8) {
      BottomButton(
        title: "이전",
        style: .secondary
      ) {
        viewStore.send(.previousStepTapped)
      }

      BottomButton(
        title: "다음",
        style: isNextEnabled ? .primary : .secondary
      ) {
        viewStore.send(.nextStepTapped)
      }
      .disabled(!isNextEnabled)
    }
  }

  private func highlightedText(fullText: String, searchText: String) -> Text {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      return Text(fullText)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale900)
    }

    var result = Text("")
    var cursor = fullText.startIndex
    let end = fullText.endIndex

    while let range = fullText.range(of: trimmed, options: .caseInsensitive, range: cursor..<end) {
      let before = String(fullText[cursor..<range.lowerBound])
      if !before.isEmpty {
        result = result + Text(before).foregroundColor(AppColor.grayscale900)
      }

      let match = String(fullText[range])
      result = result + Text(match).foregroundColor(AppColor.grayscale500)

      cursor = range.upperBound
    }

    let tail = String(fullText[cursor..<end])
    if !tail.isEmpty {
      result = result + Text(tail).foregroundColor(AppColor.grayscale900)
    }

    return result.font(.pretendardBody2)
  }
}
