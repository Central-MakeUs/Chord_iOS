import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

public struct MenuRegistrationStep1View: View {
  let store: StoreOf<MenuRegistrationFeature>
  @Environment(\.dismiss) private var dismiss
  @State private var isCategorySheetPresented = false
  @State private var selectedCategoryDraft = "음료"
  @FocusState private var isPriceFieldFocused: Bool
  @State private var priceFieldText: String = ""

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
        .padding(.bottom, 24)


        nameInputSection(viewStore: viewStore)
          .padding(.horizontal, 20)
          .padding(.top, 10)

        if viewStore.showSuggestions {
          suggestionList(viewStore: viewStore)
        } else {
          ScrollView {
            VStack(spacing: 0) {
              if !viewStore.menuName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewStore.isTemplateApplied {
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
          }
        )
        .presentationDetents([.height(360)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
      }
      .sheet(isPresented: $isCategorySheetPresented) {
        MenuCategoryBottomSheet(
          selectedCategory: $selectedCategoryDraft,
          onConfirm: {
            viewStore.send(.categorySelected(selectedCategoryDraft))
            isCategorySheetPresented = false
          }
        )
        .presentationDetents([.height(300)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.white)
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
    }
  }

  private func dismissKeyboard() {
    isPriceFieldFocused = false
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
  }

  private func digitsOnly(from value: String) -> String {
    value.filter { $0.isNumber }
  }

  private func formattedWithComma(_ digits: String) -> String {
    guard let value = Int(digits) else { return digits }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? digits
  }

  private func syncPriceFieldText(with viewStore: ViewStoreOf<MenuRegistrationFeature>) {
    let rawDigits = digitsOnly(from: viewStore.price)
    guard !rawDigits.isEmpty else {
      priceFieldText = ""
      return
    }

    if isPriceFieldFocused {
      priceFieldText = rawDigits
    } else {
      priceFieldText = "\(formattedWithComma(rawDigits))원"
    }
  }

  private var stepIndicator: some View {
    MenuRegistrationStepIndicator(phase: .step1)
  }

  private func nameInputSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 24) {
      menuNameInputField(viewStore: viewStore)
      
//      if viewStore.menuName.isEmpty {
//        HStack(spacing: 0) {
//          Spacer(minLength: 0)
//          SpeechBubbleBanner(text: "등록하실 메뉴명을 입력해주세요")
//        }
//        .padding(.top, -12)
//        .transition(.opacity)
//      }
      
      if viewStore.isTemplateApplied || !viewStore.menuName.isEmpty && !viewStore.showSuggestions {
        priceInputField(viewStore: viewStore)
      }
    }
  }

  private func priceInputField(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("가격")
        .frame(minHeight: 20)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      TextField(
        "",
        text: Binding(
          get: { priceFieldText },
          set: { newValue in
            priceFieldText = newValue
            viewStore.send(.priceChanged(digitsOnly(from: newValue)))
          }
        ),
        prompt: Text("가격을 입력해주세요")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale500)
      )
      .frame(minHeight: 30)
      .font(.pretendardSubtitle2)
      .foregroundColor(AppColor.grayscale900)
      .tint(AppColor.grayscale900)
      .keyboardType(.numberPad)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .focused($isPriceFieldFocused)
      .onAppear {
        syncPriceFieldText(with: viewStore)
      }
      .onChange(of: isPriceFieldFocused) { _, _ in
        syncPriceFieldText(with: viewStore)
      }
      .onChange(of: viewStore.price) { _, _ in
        if !isPriceFieldFocused {
          syncPriceFieldText(with: viewStore)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
        .padding(.top, 2)
    }
  }

  private func menuNameInputField(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    let isDirectInputState = viewStore.showSuggestions
      && viewStore.searchResults.isEmpty
      && !viewStore.menuName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    return VStack(alignment: .leading, spacing: 8) {
      Text("메뉴명")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        TextField(
          "",
          text: viewStore.binding(
            get: \.menuName,
            send: MenuRegistrationFeature.Action.menuNameChanged
          ),
          prompt: Text("예)아메리카노")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !viewStore.menuName.isEmpty {
          Button(action: {
            if isDirectInputState {
              viewStore.send(.directInputTapped)
            } else {
              viewStore.send(.clearMenuNameTapped)
            }
          }) {
            Group {
              if isDirectInputState {
                Image.plusCircleBlueIcon
                  .resizable()
                  .scaledToFit()
              } else {
                Image.cancelRoundedIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.grayscale500)
              }
            }
            .frame(width: 20, height: 20)
          }
          .buttonStyle(.plain)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private func filledContentSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 8) {
        infoSelectCard(
          title: "카테고리",
          value: viewStore.selectedCategory,
          onTap: {
            selectedCategoryDraft = viewStore.selectedCategory
            isCategorySheetPresented = true
          }
        )

        infoSelectCard(
          title: "제조시간",
          value: viewStore.workTimeText,
          onTap: {
            viewStore.send(.showTimePickerChanged(true))
          }
        )
      }
      .padding(.top, 24)
      .padding(.horizontal, 20)

        HStack {
            Spacer()
            if viewStore.selectedCategory == "음료" {
                workTimeHintBanner(text: "평균적인 음료의 제조시간이에요")
                  .padding(.top, 8)
                  .padding(.horizontal, 20)
            }

        }
  
    }
  }

  private func infoSelectCard(
    title: String,
    value: String,
    onTap: @escaping () -> Void
  ) -> some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 12) {
          Text(title)
              .frame(minHeight: 26)
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale700)

        HStack(spacing: 4) {
          Text(value)
            .font(.pretendardSubtitle4)
            .foregroundColor(AppColor.grayscale600)
          Image.chevronRightOutlineIcon
            .renderingMode(.template)
            .foregroundColor(AppColor.grayscale500)
        }
        .frame(minHeight: 26)

      }
      .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
      .padding(12)
      .background(AppColor.grayscale200)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    .buttonStyle(.plain)
  }

  private func workTimeHintBanner(text: String) -> some View {
    VStack(alignment: .trailing, spacing: 0) {
      Image.speechBubbleTail
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 12, height: 12)
        .foregroundColor(AppColor.grayscale800)
        .padding(.trailing, 20)
        .padding(.bottom, -2)

      Text(text)
        .font(.pretendardCaption1)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColor.grayscale800)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
  }
  


  private func suggestionList(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: 0) {
          if viewStore.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
              Text("메뉴 템플릿")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale600)

              VStack(spacing: 0) {
                Text("해당 메뉴의\n템플릿이 없어요")
                  .font(.pretendardCaption1)
                  .foregroundColor(AppColor.grayscale500)
                  .multilineTextAlignment(.center)
                  .lineSpacing(2)
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 20)
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(AppColor.grayscale200)
              .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
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
    let menuName = viewStore.menuName.trimmingCharacters(in: .whitespacesAndNewlines)
    let priceText = viewStore.price.replacingOccurrences(of: ",", with: "")
    let priceValue = Double(priceText) ?? 0
    let isNextEnabled = !menuName.isEmpty && priceValue > 0

    return BottomButton(
      title: "다음",
      style: isNextEnabled ? .primary : .secondary
    ) {
      if isNextEnabled {
        viewStore.send(.nextStepTapped)
      }
    }
    .disabled(!isNextEnabled)
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

private struct MenuCategoryBottomSheet: View {
  @Binding var selectedCategory: String
  let onConfirm: () -> Void

  private let categories = ["음료", "디저트", "푸드"]

  var body: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Text("메뉴 카테고리")
          .font(.pretendardSubtitle1)
          .foregroundColor(AppColor.grayscale900)
          .padding(.top, 20)
          .padding(.bottom, 16)

        VStack(alignment: .leading, spacing: 20) {
          ForEach(categories, id: \.self) { category in
            Button(action: { selectedCategory = category }) {
              HStack(spacing: 8) {
                Text(category)
                  .font(.pretendardBody2)
                  .foregroundColor(selectedCategory == category ? AppColor.primaryBlue500 : AppColor.grayscale900)

                if selectedCategory == category {
                  Image.checkmarkIcon
                    .renderingMode(.template)
                    .foregroundColor(AppColor.primaryBlue500)
                    .frame(width: 16, height: 16)
                }

                Spacer()
              }
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 24)

        Spacer(minLength: 12)

        BottomButton(title: "확인", style: .primary) {
          onConfirm()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
      }
    }
  }
}
