import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem
import UIKit

struct IngredientAddSheet: View {
  let store: StoreOf<MenuRegistrationFeature>
  @State private var isUnitDropdownExpanded = false
  @FocusState private var isPriceFieldFocused: Bool
  @FocusState private var isUsageFieldFocused: Bool
  @State private var customPriceFieldText: String = ""
  @State private var customUsageFieldText: String = ""

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.white
          .ignoresSafeArea()
          .onTapGesture {
            isPriceFieldFocused = false
            isUsageFieldFocused = false
            UIApplication.shared.sendAction(
              #selector(UIResponder.resignFirstResponder),
              to: nil,
              from: nil,
              for: nil
            )
          }

        VStack(spacing: 12) {
          Color.clear.frame(height: 40)

          ScrollView {
            VStack(alignment: .leading, spacing: 24) {

              VStack(alignment: .leading, spacing: 12) {

                Text(viewStore.ingredientAddName)
                  .font(.pretendardHeadline2)
                  .foregroundColor(AppColor.grayscale900)

                categoryTabs(viewStore: viewStore)
              }


              priceField(viewStore: viewStore)
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
                accentColor: AppColor.grayscale900,
                showFocusHighlight: false
              )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
          }

          addButton(viewStore: viewStore)
        }
      }
    }
  }

  private func priceField(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("가격")
        .frame(minHeight: 20)
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      TextField(
        "",
        text: Binding(
          get: { customPriceFieldText },
          set: { newValue in
            let rawDigits = digitsOnly(from: newValue)
            customPriceFieldText = rawDigits
            viewStore.send(.ingredientAddPriceChanged(rawDigits))
          }
        ),
        prompt: Text("구매하신 가격을 입력해주세요")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale500)
      )
      .frame(minHeight: 30)
      .font(.pretendardSubtitle2)
      .foregroundColor(AppColor.grayscale900)
      .tint(AppColor.grayscale900)
      .keyboardType(.numberPad)
      .focused($isPriceFieldFocused)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .onAppear {
        syncCustomPriceFieldText(with: viewStore)
      }
      .onChange(of: isPriceFieldFocused) { _, _ in
        syncCustomPriceFieldText(with: viewStore)
      }
      .onChange(of: viewStore.ingredientAddPrice) { _, _ in
        if !isPriceFieldFocused {
          syncCustomPriceFieldText(with: viewStore)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
        .padding(.top, 2)
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
        .tint(AppColor.grayscale900)
        .keyboardType(.decimalPad)
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
          text: Binding(
            get: { customUsageFieldText },
            set: { newValue in
              let sanitized = sanitizedDecimalText(removeSuffixUnit(from: newValue, unit: viewStore.ingredientAddUnit.title))
              customUsageFieldText = sanitized
              let withoutUnit = removeSuffixUnit(from: newValue, unit: viewStore.ingredientAddUnit.title)
              viewStore.send(.ingredientAddUsageAmountChanged(sanitizedDecimalText(withoutUnit)))
            }
          ),
          prompt: Text("이 메뉴에서의 재료 사용량을 입력해주세요")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .tint(AppColor.grayscale900)
        .keyboardType(.decimalPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .focused($isUsageFieldFocused)
        .onAppear {
          syncCustomUsageFieldText(with: viewStore)
        }
        .onChange(of: isUsageFieldFocused) { _, _ in
          syncCustomUsageFieldText(with: viewStore)
        }
        .onChange(of: viewStore.ingredientAddUsageAmount) { _, _ in
          if !isUsageFieldFocused {
            syncCustomUsageFieldText(with: viewStore)
          }
        }
        .onChange(of: viewStore.ingredientAddUnit) { _, _ in
          syncCustomUsageFieldText(with: viewStore)
        }
      }

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private func addButton(viewStore: ViewStoreOf<MenuRegistrationFeature>) -> some View {
    let isAddEnabled = isIngredientAddEnabled(viewStore)
    let actionTitle = viewStore.selectedIngredientIndex == nil ? "추가하기" : "완료"

    return VStack(spacing: 0) {
      BottomButton(title: actionTitle, style: isAddEnabled ? .primary : .secondary) {
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

  private func digitsOnly(from text: String) -> String {
    text.filter { $0.isNumber }
  }

  private func sanitizedDecimalText(_ value: String) -> String {
    let filtered = value.filter { $0.isNumber || $0 == "." }
    var hasDot = false
    var result = ""

    for character in filtered {
      if character == "." {
        guard !hasDot else { continue }
        hasDot = true
      }
      result.append(character)
    }

    return result
  }

  private func formattedWithComma(_ digits: String) -> String {
    guard let value = Int(digits) else { return digits }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? digits
  }

  private func removeSuffixUnit(from text: String, unit: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !unit.isEmpty, trimmed.hasSuffix(unit) else { return trimmed }
    return String(trimmed.dropLast(unit.count)).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func syncCustomPriceFieldText(with viewStore: ViewStoreOf<MenuRegistrationFeature>) {
    let rawDigits = digitsOnly(from: viewStore.ingredientAddPrice)
    guard !rawDigits.isEmpty else {
      customPriceFieldText = ""
      return
    }

    if isPriceFieldFocused {
      customPriceFieldText = rawDigits
    } else {
      customPriceFieldText = "\(formattedWithComma(rawDigits))원"
    }
  }

  private func syncCustomUsageFieldText(with viewStore: ViewStoreOf<MenuRegistrationFeature>) {
    let rawValue = sanitizedDecimalText(viewStore.ingredientAddUsageAmount)
    guard !rawValue.isEmpty else {
      customUsageFieldText = ""
      return
    }

    if isUsageFieldFocused {
      customUsageFieldText = rawValue
    } else {
      customUsageFieldText = "\(rawValue)\(viewStore.ingredientAddUnit.title)"
    }
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
        Color.clear.frame(height: 40)

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
