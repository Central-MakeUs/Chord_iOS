import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

public struct MenuRegistrationStep2View: View {
  let store: StoreOf<MenuRegistrationFeature>
  @FocusState private var isInputFocused: Bool
  @FocusState private var isRegisteredUsageFocused: Bool
  @State private var hasSectionHintExpired = false
  @State private var hasSectionHintTimerStarted = false

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let shouldShowSectionHint = !viewStore.isIngredientSelectionMode
        && viewStore.addedIngredients.isEmpty
        && !hasSectionHintExpired

      VStack(spacing: 0) {
        NavigationTopBar(onBackTap: { viewStore.send(.previousStepTapped) })

        HStack {
          stepIndicator
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 24)

        ScrollView {
          VStack(spacing: 24) {
            inputSection(viewStore: viewStore)

            if isIngredientSearchMode(viewStore: viewStore) {
              registeredIngredientsSection(viewStore: viewStore)
            } else {
              addedListSection(viewStore: viewStore)
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 100)
        }

        bottomButtons(viewStore: viewStore)
      }
      .background(Color.white.ignoresSafeArea())
      .contentShape(Rectangle())
      .simultaneousGesture(
        TapGesture().onEnded {
          dismissKeyboard()
        }
      )
      .sheet(
        isPresented: viewStore.binding(
          get: \.showIngredientDetailSheet,
          send: MenuRegistrationFeature.Action.showIngredientDetailSheetChanged
        )
      ) {
        if let index = viewStore.selectedIngredientIndex,
           index < viewStore.addedIngredients.count {
          let ingredient = viewStore.addedIngredients[index]
          IngredientDetailSheet(ingredient: ingredient)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.showRegisteredIngredientSheet,
          send: MenuRegistrationFeature.Action.showRegisteredIngredientSheetChanged
        )
      ) {
        registeredIngredientAddSheet(viewStore: viewStore)
          .presentationDetents([.height(360)])
          .presentationCornerRadius(24)
          .presentationDragIndicator(.hidden)
          .presentationBackground(Color.white)
      }
      .sheet(
        isPresented: viewStore.binding(
          get: \.showIngredientAddSheet,
          send: MenuRegistrationFeature.Action.showIngredientAddSheetChanged
        )
      ) {
        IngredientAddSheet(store: store)
          .presentationDetents([.large])
          .presentationCornerRadius(24)
          .presentationDragIndicator(.hidden)
          .presentationBackground(Color.white)
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .toastBanner(
        isPresented: viewStore.binding(
          get: \.isToastPresented,
          send: MenuRegistrationFeature.Action.showToastChanged
        ),
        message: "재료 추가가 완료되었어요!",
        duration: 1.0
      )
      .coachCoachAlert(
        isPresented: viewStore.binding(
          get: \.showIngredientDupAlert,
          send: { _ in .ingredientDupAlertCancelled }
        ),
        title: "동일한 재료명이 이미 존재합니다.\n해당 재료를 추가하시겠습니까?",
        alertType: .twoButton,
        leftButtonTitle: "네",
        rightButtonTitle: "아니오",
        leftButtonAction: { viewStore.send(.ingredientDupAlertConfirmed) },
        rightButtonAction: { viewStore.send(.ingredientDupAlertCancelled) }
      )
      .onAppear {
        startSectionHintTimerIfNeeded(shouldShowSectionHint)
      }
      .onChange(of: shouldShowSectionHint) { _, isVisible in
        startSectionHintTimerIfNeeded(isVisible)
      }
    }
  }

  private var stepIndicator: some View {
    MenuRegistrationStepIndicator(phase: .step2)
  }

  private func inputSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    HStack(spacing: 12) {
      HStack(spacing: 8) {
        TextField(
          "",
          text: viewStore.binding(
            get: \.ingredientInput,
            send: MenuRegistrationFeature.Action.ingredientInputChanged
          ),
          prompt: Text("재료명 입력")
            .font(.pretendardBody3)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .focused($isInputFocused)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !viewStore.ingredientInput.isEmpty {
          Button(action: {
            viewStore.send(.ingredientInputChanged(""))
          }) {
            Image.cancelRoundedIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale500)
              .frame(width: 20, height: 20)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(AppColor.grayscale200)
      )
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

      let isAddEnabled = !viewStore.ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      Button(action: {
        viewStore.send(.addIngredientTapped)
      }) {
        Text("추가")
          .font(.pretendardBody3)
          .foregroundColor(isAddEnabled ? AppColor.primaryBlue500 : AppColor.grayscale700)
      }
      .buttonStyle(.plain)
      .disabled(!isAddEnabled)
    }
    .animation(.easeInOut(duration: 0.2), value: viewStore.ingredientInput.isEmpty)
  }

  private func registeredIngredientsSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("등록된 재료")
            .multilineTextAlignment(.leading)
        .font(.pretendardCaption3)
        .foregroundColor(AppColor.grayscale600)
        
        if viewStore.ingredientSearchResults.isEmpty {
        VStack(spacing: 0) {
          Text("해당 이름으로\n등록된 재료가 없어요")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale500)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .background(AppColor.grayscale100)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      } else {
        VStack(spacing: 0) {
          ForEach(viewStore.ingredientSearchResults, id: \.ingredientId) { result in
            Button(action: {
              viewStore.send(.ingredientSearchResultSelected(result))
            }) {
              HStack(spacing: 10) {
                Text(highlightedText(fullText: result.ingredientName, searchText: viewStore.ingredientInput))
                  .frame(maxWidth: .infinity, alignment: .leading)

                Image.plusCircleBlueIcon
                  .resizable()
                  .frame(width: 20, height: 20)
              }
              .padding(.horizontal, 4)
              .padding(.vertical, 12)
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if result.ingredientId != viewStore.ingredientSearchResults.last?.ingredientId {
              Divider()
                .background(AppColor.grayscale200)
            }
          }
        }
      }
    }
  }

  private func isIngredientSearchMode(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> Bool {
    !viewStore.ingredientInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func registeredIngredientAddSheet(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      SheetDragHandle()

      if let draft = viewStore.registeredIngredientDraft {
        VStack(alignment: .leading, spacing: 0) {
          Text(draft.name)
            .font(.pretendardHeadline2)
            .foregroundColor(AppColor.grayscale900)
            .padding(.bottom, 18)

          Text("사용량")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.grayscale900)

          HStack(spacing: 8) {
            TextField(
              "",
              text: viewStore.binding(
                get: { $0.registeredIngredientDraft?.usageAmount ?? "" },
                send: MenuRegistrationFeature.Action.registeredIngredientUsageChanged
              ),
              prompt: Text("제조시 사용되는 용량 입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale400)
            )
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .focused($isRegisteredUsageFocused)
            .onChange(of: isRegisteredUsageFocused) { _, isFocused in
              if isFocused {
                let raw = stripUnit(from: draft.usageAmount, unit: draft.unitCode)
                if raw != draft.usageAmount {
                  viewStore.send(.registeredIngredientUsageChanged(raw))
                }
              } else {
                let appended = appendUnitIfNeeded(to: draft.usageAmount, unit: draft.unitCode)
                if appended != draft.usageAmount {
                  viewStore.send(.registeredIngredientUsageChanged(appended))
                }
              }
            }
          }
          .padding(.top, 8)

          Rectangle()
            .fill(AppColor.grayscale300)
            .frame(height: 1)
            .padding(.top, 8)

          VStack(alignment: .leading, spacing: 12) {
            Text("재료 정보")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale800)

            infoRow(label: "단가", value: "\(formatAmount(draft.baseQuantity))\(IngredientUnit.from(draft.unitCode).title)당 \(formatPrice(draft.basePrice))")
            infoRow(label: "공급업체", value: (draft.supplier?.isEmpty == false ? draft.supplier! : "-"))
          }
          .padding(12)
          .background(AppColor.grayscale200)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          .padding(.top, 14)

          Spacer(minLength: 12)

          BottomButton(
            title: "완료",
            style: draft.usageAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .primary
          ) {
            viewStore.send(.confirmAddRegisteredIngredientTapped)
          }
          .disabled(draft.usageAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .contentShape(Rectangle())
    .simultaneousGesture(
      TapGesture().onEnded {
        isRegisteredUsageFocused = false
        UIApplication.shared.sendAction(
          #selector(UIResponder.resignFirstResponder),
          to: nil,
          from: nil,
          for: nil
        )
      }
    )
  }

  private func infoRow(label: String, value: String) -> some View {
    HStack(spacing: 8) {
      Text(label)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale500)
        .frame(width: 56, alignment: .leading)

      Text(value)
        .font(.pretendardBody2)
        .foregroundColor(AppColor.grayscale700)

      Spacer()
    }
  }

  private func formatAmount(_ value: Double) -> String {
    let intValue = Int(value)
    if Double(intValue) == value {
      return "\(intValue)"
    }
    return String(format: "%.1f", value)
  }

  private func formatPrice(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let intValue = Int(value)
    let text = formatter.string(from: NSNumber(value: intValue)) ?? "\(intValue)"
    return "\(text)원"
  }

  private func stripUnit(from text: String, unit: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasSuffix(unit) {
      return String(trimmed.dropLast(unit.count)).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return trimmed
  }

  private func appendUnitIfNeeded(to text: String, unit: String) -> String {
    let raw = stripUnit(from: text, unit: unit)
      .filter { $0.isNumber || $0 == "." || $0 == "," }
    guard !raw.isEmpty else { return "" }

    let normalized = raw.replacingOccurrences(of: ",", with: "")
    if let value = Double(normalized) {
      let intValue = Int(value)
      if Double(intValue) == value {
        return "\(intValue)\(unit)"
      }
      return "\(value)\(unit)"
    }
    return "\(normalized)\(unit)"
  }

  private func highlightedText(fullText: String, searchText: String) -> AttributedString {
    var attributed = AttributedString(fullText)
    attributed.font = .pretendardBody2
    attributed.foregroundColor = AppColor.grayscale900

    if let range = attributed.range(of: searchText, options: .caseInsensitive) {
      attributed[range].foregroundColor = AppColor.primaryBlue500
    }

    return attributed
  }

  private func addedListSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    let showHint = !viewStore.isIngredientSelectionMode
      && viewStore.addedIngredients.isEmpty
      && !hasSectionHintExpired

    return ZStack(alignment: .topTrailing) {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Text("사용되는 재료")
            .font(.pretendardSubtitle3)
            .foregroundColor(AppColor.grayscale700)

          Spacer()

        if !viewStore.addedIngredients.isEmpty {
          Button(action: {
            viewStore.send(.ingredientSelectionTapped)
          }) {
            Text(viewStore.isIngredientSelectionMode ? "취소" : "선택")
              .font(.pretendardCaption1)
              .foregroundColor(viewStore.isIngredientSelectionMode ? AppColor.error : AppColor.grayscale600)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .overlay(
                RoundedRectangle(cornerRadius: 6)
                  .stroke(AppColor.grayscale300, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
        }
        .padding(.bottom, 8)

        if viewStore.addedIngredients.isEmpty {
          VStack(spacing: 8) {
            Image.infoOutlinedIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.grayscale300)
              .frame(width: 48, height: 48)

            Text("추가된 재료가 없습니다")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.grayscale500)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 40)
        } else {
          VStack(spacing: 0) {
            ForEach(Array(viewStore.addedIngredients.enumerated()), id: \.element.id) { index, item in
              VStack(spacing: 0) {
                Button(action: {
                  if viewStore.isIngredientSelectionMode {
                    viewStore.send(.ingredientSelectionToggled(item.id))
                  } else {
                    viewStore.send(.ingredientTapped(index))
                  }
                }) {
                  HStack(spacing: 12) {
                    if viewStore.isIngredientSelectionMode {
                      selectionIndicator(isSelected: viewStore.selectedIngredientIDs.contains(item.id))
                    }

                    Text(item.name)
                      .font(.pretendardSubtitle3)
                      .foregroundColor(AppColor.grayscale900)

                    Spacer()

                    HStack(spacing: 8) {
                      Text(item.formattedAmount)
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.grayscale500)

                      Text(item.formattedPrice)
                        .font(.pretendardBody2)
                        .foregroundColor(AppColor.grayscale500)

                      Image.chevronRightOutlineIcon
                        .renderingMode(.template)
                        .foregroundColor(AppColor.grayscale300)
                    }
                  }
                  .padding(.vertical, 16)
                  .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Rectangle()
                  .fill(AppColor.grayscale200)
                  .frame(height: 1)
              }
            }
          }
        }
      }

      if showHint {
        sectionHintBubble(text: "필요한 재료가 더 있으신가요?\n직접 입력해서 추가해보세요")
          .offset(y: -24)
      }
    }
  }

  private func sectionHintBubble(text: String) -> some View {
    VStack(alignment: .trailing, spacing: 0) {
      Image.speechBubbleTail
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 13, height: 13)
        .foregroundColor(AppColor.grayscale800)
        .padding(.trailing, 20)
        .padding(.bottom, -2)

      Text(text)
        .font(.pretendardCaption2)
        .foregroundColor(.white)
        .lineSpacing(2)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColor.grayscale800)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
  }

  private func selectionIndicator(isSelected: Bool) -> some View {
    (isSelected ? Image.checkBoxCircleCheckedIcon : Image.checkBoxCircleIcon)
      .renderingMode(.original)
      .resizable()
      .frame(width: 28, height: 28)
  }

  private func dismissKeyboard() {
    isInputFocused = false
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
  }

  private func startSectionHintTimerIfNeeded(_ isVisible: Bool) {
    guard isVisible, !hasSectionHintTimerStarted else { return }
    hasSectionHintTimerStarted = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      hasSectionHintExpired = true
    }
  }

  private func bottomButtons(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      HStack(spacing: 12) {
        if viewStore.isIngredientSelectionMode {
          let selectedCount = viewStore.selectedIngredientIDs.count
          BottomButton(
            title: selectedCount > 0 ? "\(selectedCount)개 삭제" : "삭제",
            style: selectedCount > 0 ? .primary : .secondary
          ) {
            if selectedCount > 0 {
              viewStore.send(.deleteSelectedIngredientsTapped)
            }
          }
          .disabled(selectedCount == 0)
        } else {
          BottomButton(
            title: "완료",
            style: viewStore.addedIngredients.isEmpty ? .secondary : .primary
          ) {
            if !viewStore.addedIngredients.isEmpty {
              viewStore.send(.finalCompleteTapped)
            }
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 20)
      .background(Color.white)
    }
  }
}
