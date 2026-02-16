import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

struct IngredientAddSheet: View {
  let store: StoreOf<MenuRegistrationFeature>
  @State private var isUnitDropdownExpanded = false

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 12) {
        SheetDragHandle()

        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
    
            VStack(alignment: .leading, spacing: 12) {
              
              Text(viewStore.ingredientAddName)
                .font(.pretendardHeadline2)
                .foregroundColor(AppColor.grayscale900)
              
              categoryTabs(viewStore: viewStore)
            }


            UnderlinedTextField(
              text: viewStore.binding(
                get: \.ingredientAddPrice,
                send: MenuRegistrationFeature.Action.ingredientAddPriceChanged
              ),
              title: "가격",
              placeholder: "구매하신 가격을 입력해주세요",
              accentColor: AppColor.grayscale500,
              keyboardType: .numberPad
            )
            .padding(.bottom, 12)

            purchaseAmountField(viewStore: viewStore)
                  .padding(.bottom, 12)

              
            usageAmountField(viewStore: viewStore)
                  .padding(.bottom, 12)

              
            UnderlinedTextField(
              text: viewStore.binding(
                get: \.ingredientAddSupplier,
                send: MenuRegistrationFeature.Action.ingredientAddSupplierChanged
              ),
              title: "공급업체",
              placeholder: "공급업체명을 알려주세요 (선택)",
              accentColor: AppColor.grayscale300
            )
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 100)
        }

        addButton(viewStore: viewStore)
      }
      .background(Color.white.ignoresSafeArea())
      .contentShape(Rectangle())
      .simultaneousGesture(
        TapGesture().onEnded {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }
      )
    }
  }

  private func categoryTabs(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    HStack(spacing: 8) {
      categoryTab(
        label: "식재료",
        isSelected: viewStore.ingredientAddCategory == "식재료"
      ) {
        viewStore.send(.ingredientAddCategorySelected("식재료"))
      }

      categoryTab(
        label: "운영 재료",
        isSelected: viewStore.ingredientAddCategory == "운영 재료"
      ) {
        viewStore.send(.ingredientAddCategorySelected("운영 재료"))
      }

      Spacer()
    }
  }

  private func categoryTab(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(label)
        .font(.pretendardCaption1)
        .foregroundColor(isSelected ? .white : AppColor.grayscale600)
        .frame(minHeight: 20)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale200)
        )
    }
    .buttonStyle(.plain)
  }

  private func purchaseAmountField(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("구매 용량")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        TextField(
          "",
          text: viewStore.binding(
            get: \.ingredientAddPurchaseAmount,
            send: MenuRegistrationFeature.Action.ingredientAddPurchaseAmountChanged
          ),
          prompt: Text("구매하신 총 용량을 입력해주세요")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !viewStore.ingredientAddPurchaseAmount.isEmpty {
          HStack(spacing: 8) {
            Text("단위")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale500)

            Rectangle()
              .fill(AppColor.grayscale300)
              .frame(width: 1, height: 14)

            Button {
              isUnitDropdownExpanded.toggle()
            } label: {
              HStack(spacing: 4) {
                Text(viewStore.ingredientAddUnit.title)
                  .font(.pretendardBody2)
                  .foregroundColor(AppColor.grayscale900)
                Image.chevronDownOutlineIcon
                  .font(.system(size: 12))
                  .foregroundColor(AppColor.grayscale900)
                  .rotationEffect(.degrees(isUnitDropdownExpanded ? 180 : 0))
              }
            }
            .buttonStyle(.plain)
          }
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
    .overlay(alignment: .topTrailing) {
      if isUnitDropdownExpanded {
        VStack(spacing: 0) {
          ForEach(Array(IngredientUnit.allCases.enumerated()), id: \.element) { index, unit in
            Button {
              viewStore.send(.ingredientAddUnitSelected(unit))
              isUnitDropdownExpanded = false
            } label: {
              Text(unit.title)
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale900)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(height: 36)
                .padding(.trailing, 12)
            }
            .buttonStyle(.plain)

            if index < IngredientUnit.allCases.count - 1 {
              Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
            }
          }
        }
        .background(AppColor.grayscale200)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        .frame(width: 70)
        .offset(y: 50)
      }
    }
    .zIndex(isUnitDropdownExpanded ? 1000 : 0)
    .animation(.easeInOut(duration: 0.15), value: isUnitDropdownExpanded)
    .animation(.easeInOut(duration: 0.2), value: viewStore.ingredientAddPurchaseAmount.isEmpty)
  }

  private func usageAmountField(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("재료 사용량")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        TextField(
          "",
          text: viewStore.binding(
            get: \.ingredientAddUsageAmount,
            send: MenuRegistrationFeature.Action.ingredientAddUsageAmountChanged
          ),
          prompt: Text("이 메뉴에서의 재료 사용량을 입력해주세요")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !viewStore.ingredientAddPurchaseAmount.isEmpty {
          Text(viewStore.ingredientAddUnit.title)
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale700)
            .frame(minWidth: 20, alignment: .trailing)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private func addButton(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    let isAddEnabled = isIngredientAddEnabled(viewStore)

    return VStack(spacing: 0) {
      BottomButton(title: "추가하기", style: isAddEnabled ? .primary : .secondary) {
        viewStore.send(.confirmAddIngredientTapped)
      }
      .disabled(!isAddEnabled)
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 34)
      .background(Color.white)
    }
  }

  private func isIngredientAddEnabled(_ viewStore: ViewStoreOf<MenuRegistrationFeature>) -> Bool {
    let price = Double(viewStore.ingredientAddPrice.replacingOccurrences(of: ",", with: "")) ?? 0
    let purchaseAmount = Double(viewStore.ingredientAddPurchaseAmount.replacingOccurrences(of: ",", with: "")) ?? 0
    let usageAmount = Double(viewStore.ingredientAddUsageAmount.replacingOccurrences(of: ",", with: "")) ?? 0
    return price > 0 && purchaseAmount > 0 && usageAmount > 0
  }
}

@Reducer
public struct PrepareTimeSheetFeature {
  public struct State: Equatable {
    var draftMinutes: Int
    var draftSeconds: Int
    var initialMinutes: Int
    var initialSeconds: Int

    public init(minutes: Int, seconds: Int) {
      self.draftMinutes = minutes
      self.draftSeconds = seconds
      self.initialMinutes = minutes
      self.initialSeconds = seconds
    }
  }

  public enum Action: Equatable {
    case minutesChanged(Int)
    case secondsChanged(Int)
    case confirmTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .minutesChanged(minutes):
        state.draftMinutes = minutes
        return .none
      case let .secondsChanged(seconds):
        state.draftSeconds = seconds
        return .none
      case .confirmTapped:
        return .none
      }
    }
  }
}

public struct PrepareTimeSheetView: View {
  let store: StoreOf<PrepareTimeSheetFeature>
  let onComplete: (Int, Int) -> Void

  public init(
    store: StoreOf<PrepareTimeSheetFeature>,
    onComplete: @escaping (Int, Int) -> Void
  ) {
    self.store = store
    self.onComplete = onComplete
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        SheetDragHandle()

        Text("제조 시간")
          .font(.pretendardHeadline2)
          .foregroundColor(AppColor.grayscale900)
          .padding(.top, 28)

        ZStack {
          Rectangle()
            .fill(AppColor.primaryBlue100)
            .frame(height: 30)
            .cornerRadius(8)

          HStack(spacing: 0) {
            Spacer()
            CustomWheelPicker(
              selection: viewStore.binding(
                get: \.draftMinutes,
                send: PrepareTimeSheetFeature.Action.minutesChanged
              ),
              range: 0..<60
            )
            .frame(width: 50, height: 200)

            Spacer()
              .frame(width: 62)

            CustomWheelPicker(
              selection: viewStore.binding(
                get: \.draftSeconds,
                send: PrepareTimeSheetFeature.Action.secondsChanged
              ),
              range: 0..<60
            )
            .frame(width: 50, height: 160)
            Spacer()
          }

          HStack(spacing: 0) {
            Spacer()
            Text("분")
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 50, alignment: .trailing)
              .offset(x: 4)

            Spacer()
              .frame(width: 62)

            Text("초")
              .font(.pretendardBody3)
              .foregroundColor(AppColor.grayscale900)
              .frame(width: 50, alignment: .trailing)
              .offset(x: 4)
            Spacer()
          }
        }
        .frame(height: 150)
        .padding(.horizontal, 20)
        .padding(.top, 24)

        Spacer(minLength: 20)

        BottomButton(
          title: "완료",
          style: .primary
        ) {
          viewStore.send(.confirmTapped)
          onComplete(viewStore.draftMinutes, viewStore.draftSeconds)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(AppColor.grayscale100)
    }
    .presentationCornerRadius(24)
  }
}

// MARK: - Custom Wheel Picker (UIKit-based)
struct CustomWheelPicker: UIViewRepresentable {
  @Binding var selection: Int
  let range: Range<Int>

  func makeUIView(context: Context) -> UIView {
    let containerView = UIView()

    let picker = UIPickerView()
    picker.delegate = context.coordinator
    picker.dataSource = context.coordinator

    if range.contains(selection) {
      picker.selectRow(selection - range.lowerBound, inComponent: 0, animated: false)
    }

    containerView.addSubview(picker)
    picker.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      picker.topAnchor.constraint(equalTo: containerView.topAnchor),
      picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      picker.heightAnchor.constraint(equalToConstant: 200)
    ])

    DispatchQueue.main.async {
      picker.reloadAllComponents()
    }

    return containerView
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    guard let picker = uiView.subviews.first(where: { $0 is UIPickerView }) as? UIPickerView else { return }

    if range.contains(selection) {
      let row = selection - range.lowerBound
      if picker.selectedRow(inComponent: 0) != row {
        picker.selectRow(row, inComponent: 0, animated: true)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let parent: CustomWheelPicker

    init(_ parent: CustomWheelPicker) {
      self.parent = parent
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      parent.range.count
    }

    func pickerView(
      _ pickerView: UIPickerView,
      viewForRow row: Int,
      forComponent component: Int,
      reusing view: UIView?
    ) -> UIView {
      if pickerView.subviews.count > 1 {
        pickerView.subviews[1].backgroundColor = .clear
      }

      let value = parent.range.lowerBound + row
      let isSelected = pickerView.selectedRow(inComponent: component) == row

      let label = UILabel()
      label.text = "\(value)"
      label.textAlignment = .center
      label.font = UIFont(name: "Pretendard-Medium", size: 20)!
      label.textColor = isSelected
      ? UIColor.black
        : UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0)
      label.backgroundColor = .clear

      return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      36
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let value = parent.range.lowerBound + row
      parent.selection = value
      pickerView.reloadAllComponents()
    }
  }
}
