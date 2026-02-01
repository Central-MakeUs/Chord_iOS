import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct MenuRegistrationStep2View: View {
  let store: StoreOf<MenuRegistrationFeature>

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

            if !viewStore.templateIngredients.isEmpty {
              templateListSection(viewStore: viewStore)
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 100)
        }

        bottomButtons(viewStore: viewStore)
      }
      .background(Color.white.ignoresSafeArea())
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
        }
      }
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
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
      
      VStack(alignment: .leading, spacing: 4) {
        Text("재료 추가")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale900)
        
        Text("메뉴에 필요한 재료를 추가해주세요")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)
      }
    }
  }

  private func inputSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("재료명")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale900)

        UnderlinedTextField(
          text: viewStore.binding(
            get: \.ingredientInput,
            send: MenuRegistrationFeature.Action.ingredientInputChanged
          ),
          title: nil,
          placeholder: "추가할 재료명을 입력해주세요",
          placeholderColor: AppColor.grayscale400,
          accentColor: AppColor.primaryBlue500,
          trailingIcon: !viewStore.ingredientInput.isEmpty ? Image.cancelRoundedIcon : nil,
          onTrailingTap: {
            viewStore.send(.ingredientInputChanged(""))
          }
        )
      }
      
      if !viewStore.ingredientInput.isEmpty {
        Button(action: {
          viewStore.send(.addIngredientTapped)
        }) {
          HStack {
            Image.plusIcon
              .renderingMode(.template)
              .foregroundColor(AppColor.primaryBlue500)
              .frame(width: 20, height: 20)
            
            Text("재료 추가")
              .font(.pretendardBody2)
              .foregroundColor(AppColor.primaryBlue500)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(AppColor.primaryBlue100)
          .cornerRadius(8)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .animation(.easeInOut(duration: 0.2), value: viewStore.ingredientInput.isEmpty)
  }

  private func addedListSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("재료 리스트")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale900)

        Spacer()

        if !viewStore.addedIngredients.isEmpty {
          Text("\(viewStore.addedIngredients.count)개")
            .font(.pretendardCaption1)
            .foregroundColor(AppColor.primaryBlue500)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppColor.primaryBlue100)
            .cornerRadius(12)
        }
      }

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
        .background(Color.white)
        .cornerRadius(12)
      } else {
        VStack(spacing: 0) {
          ForEach(Array(viewStore.addedIngredients.enumerated()), id: \.element.id) { index, item in
            Button(action: {
              viewStore.send(.ingredientTapped(index))
            }) {
              HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                  Text(item.name)
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  
                  Text(item.formattedAmount)
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.grayscale500)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .trailing, spacing: 4) {
                  Text(item.formattedPrice)
                    .font(.pretendardSubtitle3)
                    .foregroundColor(AppColor.grayscale900)
                  
                  Text("단위당")
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.grayscale500)
                }
                
                Image.chevronRightOutlineIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.grayscale400)
                  .frame(width: 16, height: 16)
              }
              .padding(.vertical, 16)
              .padding(.horizontal, 16)
              .background(Color.white)
              .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if index < viewStore.addedIngredients.count - 1 {
              Spacer().frame(height: 8)
            }
          }
        }

        if !viewStore.addedIngredients.isEmpty {
          HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
              Text("총 재료비")
                .font(.pretendardCaption2)
                .foregroundColor(AppColor.grayscale600)
              Text(viewStore.formattedTotalCost)
                .font(.pretendardTitle2)
                .foregroundColor(AppColor.primaryBlue600)
            }
          }
          .padding(.top, 16)
          .padding(.horizontal, 16)
          .padding(.vertical, 16)
          .background(AppColor.primaryBlue100)
          .cornerRadius(12)
        }
      }
    }
  }

  private func templateListSection(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("템플릿 재료")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale900)
        
        Spacer()
        
        Text("추천")
          .font(.pretendardCaption2)
          .foregroundColor(Color.orange)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(8)
      }

      VStack(spacing: 8) {
        ForEach(Array(viewStore.templateIngredients.enumerated()), id: \.offset) { index, item in
          Button(action: {
            viewStore.send(.templateIngredientTapped(index))
          }) {
            HStack(spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text(item.ingredientName)
                  .font(.pretendardSubtitle3)
                  .foregroundColor(AppColor.grayscale900)
                  .frame(maxWidth: .infinity, alignment: .leading)
                

              }

              Spacer()

              VStack(spacing: 4) {
                Image.plusCircleBlueIcon
                  .renderingMode(.template)
                  .foregroundColor(AppColor.primaryBlue500)
                  .frame(width: 24, height: 24)
                
                Text("추가")
                  .font(.pretendardCaption2)
                  .foregroundColor(AppColor.primaryBlue500)
              }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
    }
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
            viewStore.send(.completeTapped)
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
