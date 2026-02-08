import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

public struct MenuRegistrationStep2View: View {
  let store: StoreOf<MenuRegistrationFeature>
  @FocusState private var isInputFocused: Bool

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        NavigationTopBar(onBackTap: { viewStore.send(.previousStepTapped) })

        HStack {
          stepIndicator
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)

        ScrollView {
          VStack(spacing: 24) {
            inputSection(viewStore: viewStore)
            
            addedListSection(viewStore: viewStore)
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
    }
  }

  private var stepIndicator: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 4) {
        Circle()
          .fill(AppColor.primaryBlue500)
          .overlay(
            Image.checkmarkIcon
              .renderingMode(.template)
              .foregroundColor(.white)

          )
          .frame(width: 24, height: 24)

        Rectangle()
          .fill(AppColor.primaryBlue500)
          .frame(height: 2)

        Circle()
          .fill(AppColor.primaryBlue500)
          .frame(width: 24, height: 24)
          .overlay(
            Text("2")
              .font(.pretendardCaption2.weight(.semibold))
              .foregroundColor(.white)
          )
      }
      .frame(width: 80)
    }
  }

  private func inputSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("재료명")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale900)

        VStack(spacing: 8) {
          HStack(alignment: .bottom, spacing: 8) {
            TextField(
              "",
              text: viewStore.binding(
                get: \.ingredientInput,
                send: MenuRegistrationFeature.Action.ingredientInputChanged
              ),
              prompt: Text("추가할 재료명을 입력해주세요")
                .font(.pretendardBody2)
                .foregroundColor(AppColor.grayscale400)
            )
            .font(.pretendardBody2)
            .foregroundColor(AppColor.grayscale900)
            .focused($isInputFocused)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .frame(height: 24)

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
            
            Button(action: {
              viewStore.send(.addIngredientTapped)
            }) {
              Image.plusCircleBlueIcon
                .resizable()
                .frame(width: 24, height: 24)
            }
          }
          
          Rectangle()
            .fill(isInputFocused ? AppColor.primaryBlue500 : AppColor.grayscale300)
            .frame(height: 1)
        }
      }
    }
    .animation(.easeInOut(duration: 0.2), value: viewStore.ingredientInput.isEmpty)
  }

  private func addedListSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("재료 리스트")
          .font(.pretendardSubtitle3)
          .foregroundColor(AppColor.grayscale700)

        Spacer()

        if !viewStore.addedIngredients.isEmpty {
          Button(action: {}) {
            Text("선택")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale600)
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
      .padding(.bottom, 16)

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
              HStack {
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
                }
              }
              .padding(.vertical, 16)

              Rectangle()
                .fill(AppColor.grayscale200)
                .frame(height: 1)
            }
          }
        }
      }
    }
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

  private func bottomButtons(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(spacing: 0) {
      Divider()
        .background(AppColor.grayscale200)
      
      HStack(spacing: 12) {
        BottomButton(
          title: "이전",
          style: .secondary
        ) {
          viewStore.send(.previousStepTapped)
        }

        BottomButton(
          title: "완료",
          style: viewStore.addedIngredients.isEmpty ? .secondary : .primary
        ) {
          if !viewStore.addedIngredients.isEmpty {
            viewStore.send(.finalCompleteTapped)
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
