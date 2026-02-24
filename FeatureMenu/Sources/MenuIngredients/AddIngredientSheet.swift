import SwiftUI
import CoreModels
import DesignSystem
import DataLayer
import ComposableArchitecture

public struct AddIngredientSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var ingredientName: String = ""
  @State private var searchResults: [SearchMyIngredientsResponse] = []
  @State private var searchTask: Task<Void, Never>?
  @State private var detailTask: Task<Void, Never>?
  @State private var registeredIngredientDraft: RegisteredIngredientDraft?
  @State private var customIngredientDraft: CustomIngredientDraft?
  @State private var isDetailLoading: Bool = false
  @State private var detailLoadFailed: Bool = false
  @State private var isUnitDropdownExpanded: Bool = false
  @FocusState private var isUsageFocused: Bool
  @FocusState private var isCustomPriceFocused: Bool

  @Dependency(\.ingredientRepository) var ingredientRepository

  let onAdd: (IngredientItem) -> Void

  public init(onAdd: @escaping (IngredientItem) -> Void) {
    self.onAdd = onAdd
  }

  public var body: some View {
    VStack(spacing: 0) {
      if customIngredientDraft != nil {
        customIngredientDetailContent
      } else if registeredIngredientDraft != nil {
        registeredIngredientDetailContent
      } else {
        addRootContent
      }
    }
    .background(Color.white)
    .presentationDetents(currentDetents)
  }

  private var currentDetents: Set<PresentationDetent> {
    if registeredIngredientDraft != nil && customIngredientDraft == nil {
      return [.height(430)]
    }
    return [.large]
  }

  private var addRootContent: some View {
    VStack(spacing: 0) {
      Color.clear.frame(height: 40)

      Text("재료 추가")
        .font(.pretendardHeadline2)
        .foregroundColor(AppColor.grayscale900)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 16)

      ingredientInputRow
        .padding(.horizontal, 20)

      Divider()
        .background(AppColor.grayscale300)
        .padding(.top, 12)
        .padding(.bottom, 10)

      VStack(alignment: .leading, spacing: 12) {
        Text("등록된 재료")
          .font(.pretendardCaption1)
          .foregroundColor(AppColor.grayscale600)

        if isDetailLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .padding(.vertical, 12)
        } else if detailLoadFailed {
          Text("재료 정보를 불러오지 못했어요")
            .font(.pretendardBody3)
            .foregroundColor(AppColor.semanticWarningText)
        }

        if !searchResults.isEmpty {
          searchResultsSection
        }
      }
      .padding(.horizontal, 20)
      .frame(maxWidth: .infinity, alignment: .leading)

      Spacer()
        .frame(maxWidth: .infinity)
    }
  }

  private var ingredientInputRow: some View {
    HStack(spacing: 12) {
      TextField("", text: $ingredientName)
        .font(.pretendardBody3)
        .foregroundColor(AppColor.grayscale900)
        .placeholder(when: ingredientName.isEmpty) {
          Text("재료명 입력")
            .font(.pretendardBody3)
            .foregroundColor(AppColor.grayscale400)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(AppColor.grayscale200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onChange(of: ingredientName) { _, newValue in
          detailLoadFailed = false
          performSearch(query: newValue)
        }

      Button(action: presentCustomIngredientDraft) {
        Text("추가")
          .font(.pretendardBody2)
          .foregroundColor(
            ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? AppColor.grayscale400
            : AppColor.primaryBlue500
          )
      }
      .buttonStyle(.plain)
      .disabled(ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
  }

  private var searchResultsSection: some View {
    VStack(spacing: 0) {
      ForEach(searchResults, id: \.ingredientId) { result in
        searchResultRow(result: result)
      }
    }
  }

  private func searchResultRow(result: SearchMyIngredientsResponse) -> some View {
    HStack {
      Text(highlightedText(fullText: result.ingredientName, searchText: ingredientName))

      Spacer()

      Button {
        loadRegisteredIngredientDraft(result)
      } label: {
        Image.plusCircleBlueIcon
          .resizable()
          .frame(width: 24, height: 24)
      }
      .buttonStyle(.plain)
    }
    .padding(.vertical, 12)
  }

  private var registeredIngredientDetailContent: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()
        .onTapGesture {
          isUsageFocused = false
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }

      VStack(spacing: 0) {
        Color.clear.frame(height: 40)

        if let draft = registeredIngredientDraft {
          VStack(alignment: .leading, spacing: 0) {
            Text(draft.name)
              .font(.pretendardHeadline2)
              .foregroundColor(AppColor.grayscale900)
              .padding(.bottom, 18)

            Text("사용량")
              .font(.pretendardCaption1)
              .foregroundColor(AppColor.grayscale900)

            TextField(
              "",
              text: Binding(
                get: {
                  guard let draft = registeredIngredientDraft else { return "" }
                  if isUsageFocused {
                    return stripUnit(from: draft.usageAmount, unit: draft.unitCode)
                      .replacingOccurrences(of: ",", with: "")
                  }
                  return appendUnitIfNeeded(to: draft.usageAmount, unit: draft.unitCode)
                },
                set: { newValue in
                  guard let unit = registeredIngredientDraft?.unitCode else { return }
                  let raw = stripUnit(from: newValue, unit: unit)
                    .replacingOccurrences(of: ",", with: "")
                  registeredIngredientDraft?.usageAmount = sanitizeDecimalsAndCommas(raw)
                }
              ),
              prompt: Text("제조시 사용되는 용량 입력")
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale400)
            )
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
            .tint(AppColor.grayscale900)
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .focused($isUsageFocused)
            .padding(.top, 8)

            Rectangle()
              .fill(AppColor.grayscale300)
              .frame(height: 1)
              .padding(.top, 8)

            VStack(alignment: .leading, spacing: 12) {
              Text("재료 정보")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale800)

              infoRow(label: "단가", value: unitPriceText(draft))
              infoRow(label: "공급업체", value: draft.supplier?.isEmpty == false ? draft.supplier! : "-")
            }
            .padding(12)
            .background(AppColor.grayscale200)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.top, 14)

            Spacer(minLength: 12)

            BottomButton(
              title: "재료 추가",
              style: isUsageEmpty(draft) ? .secondary : .primary
            ) {
              isUsageFocused = false
              confirmRegisteredIngredientAdd()
            }
            .disabled(isUsageEmpty(draft))
            .padding(.bottom, 12)
          }
          .padding(.horizontal, 20)
        }
      }
    }
  }

  private var customIngredientDetailContent: some View {
    ZStack {
      Color.white
        .ignoresSafeArea()
        .onTapGesture {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }

      VStack(spacing: 12) {
        Color.clear.frame(height: 40)

        if let draft = customIngredientDraft {
          ScrollView {
            VStack(alignment: .leading, spacing: 24) {
              VStack(alignment: .leading, spacing: 12) {
                Text(draft.name)
                  .font(.pretendardHeadline2)
                  .foregroundColor(AppColor.grayscale900)

                customCategoryTabs
              }

              customPriceField
                .padding(.bottom, 12)

              customPurchaseAmountField
                .padding(.bottom, 12)

              customUsageAmountField
                .padding(.bottom, 12)

              UnderlinedTextField(
                text: Binding(
                  get: { customIngredientDraft?.supplier ?? "" },
                  set: { customIngredientDraft?.supplier = $0 }
                ),
                title: "공급업체",
                placeholder: "공급업체명을 알려주세요 (선택)",
                accentColor: AppColor.grayscale300,
                showFocusHighlight: false
              )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
          }

          BottomButton(title: "추가하기", style: isCustomAddEnabled(draft) ? .primary : .secondary) {
            confirmCustomIngredientAdd()
          }
          .disabled(!isCustomAddEnabled(draft))
          .padding(.horizontal, 20)
          .padding(.top, 16)
          .padding(.bottom, 34)
          .background(Color.white)
        }
      }
    }
  }

  private var customPriceField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("가격")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      TextField(
        "",
        text: Binding(
          get: {
            let rawDigits = digitsOnly(from: customIngredientDraft?.price ?? "")
            guard !rawDigits.isEmpty else { return "" }
            if isCustomPriceFocused {
              return rawDigits
            }
            return "\(formattedWithComma(rawDigits))원"
          },
          set: { newValue in
            customIngredientDraft?.price = digitsOnly(from: newValue)
          }
        ),
        prompt: Text("구매하신 가격을 입력해주세요")
          .font(.pretendardSubtitle2)
          .foregroundColor(AppColor.grayscale500)
      )
      .font(.pretendardSubtitle2)
      .foregroundColor(AppColor.grayscale900)
      .tint(AppColor.grayscale900)
      .keyboardType(.numberPad)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .focused($isCustomPriceFocused)

      Rectangle()
        .fill(AppColor.grayscale300)
        .frame(height: 1)
    }
  }

  private var customCategoryTabs: some View {
    HStack(spacing: 8) {
      customCategoryTab(label: "식재료", value: "식재료")
      customCategoryTab(label: "운영 재료", value: "운영 재료")
      Spacer()
    }
  }

  private func customCategoryTab(label: String, value: String) -> some View {
    let isSelected = customIngredientDraft?.category == value
    return Button {
      customIngredientDraft?.category = value
    } label: {
      Text(label)
        .font(.pretendardCaption1)
        .foregroundColor(isSelected == true ? .white : AppColor.grayscale600)
        .frame(minHeight: 20)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(isSelected == true ? AppColor.primaryBlue500 : AppColor.grayscale200)
        )
    }
    .buttonStyle(.plain)
  }

  private var customPurchaseAmountField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("구매 용량")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        TextField(
          "",
          text: Binding(
            get: { customIngredientDraft?.purchaseAmount ?? "" },
            set: { customIngredientDraft?.purchaseAmount = sanitizeDecimalsAndCommas($0) }
          ),
          prompt: Text("구매하신 총 용량을 입력해주세요")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.decimalPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !(customIngredientDraft?.purchaseAmount.isEmpty ?? true) {
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
                Text(customIngredientDraft?.unit.title ?? IngredientUnit.g.title)
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
              customIngredientDraft?.unit = unit
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
  }

  private var customUsageAmountField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("재료 사용량")
        .font(.pretendardCaption1)
        .foregroundColor(AppColor.grayscale900)

      HStack(spacing: 8) {
        TextField(
          "",
          text: Binding(
            get: { customIngredientDraft?.usageAmount ?? "" },
            set: { customIngredientDraft?.usageAmount = sanitizeDecimalsAndCommas($0) }
          ),
          prompt: Text("이 메뉴에서의 재료 사용량을 입력해주세요")
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale500)
        )
        .font(.pretendardSubtitle2)
        .foregroundColor(AppColor.grayscale900)
        .keyboardType(.decimalPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if !(customIngredientDraft?.purchaseAmount.isEmpty ?? true) {
          Text(customIngredientDraft?.unit.title ?? IngredientUnit.g.title)
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

  private func highlightedText(fullText: String, searchText: String) -> AttributedString {
    var attributedString = AttributedString(fullText)
    attributedString.foregroundColor = AppColor.grayscale900
    attributedString.font = .pretendardSubtitle2

    if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
      attributedString[range].foregroundColor = AppColor.primaryBlue500
    }

    return attributedString
  }

  private func performSearch(query: String) {
    searchTask?.cancel()

    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      searchResults = []
      return
    }

    searchTask = Task {
      try? await Task.sleep(for: .milliseconds(300))

      guard !Task.isCancelled else { return }

      do {
        let results = try await ingredientRepository.searchIngredients(query)
        await MainActor.run {
          self.searchResults = results
        }
      } catch {
        await MainActor.run {
          self.searchResults = []
        }
      }
    }
  }

  private func loadRegisteredIngredientDraft(_ result: SearchMyIngredientsResponse) {
    detailTask?.cancel()
    isDetailLoading = true
    detailLoadFailed = false
    customIngredientDraft = nil
    isUnitDropdownExpanded = false
    detailTask = Task {
      do {
        let item = try await ingredientRepository.fetchIngredientDetail(result.ingredientId)
        let parsed = parseAmountAndUnit(from: item.amount)
        let basePrice = parsePrice(from: item.price)
        await MainActor.run {
          registeredIngredientDraft = RegisteredIngredientDraft(
            ingredientId: result.ingredientId,
            name: result.ingredientName,
            unitCode: parsed.unit,
            baseQuantity: parsed.amount,
            basePrice: basePrice,
            supplier: item.supplier,
            usageAmount: ""
          )
          isDetailLoading = false
        }
      } catch {
        await MainActor.run {
          isDetailLoading = false
          detailLoadFailed = true
        }
      }
    }
  }

  private func confirmRegisteredIngredientAdd() {
    guard let draft = registeredIngredientDraft else { return }
    let numericUsage = draft.usageAmount
      .filter { $0.isNumber || $0 == "." || $0 == "," }
      .replacingOccurrences(of: ",", with: "")
    guard let usageAmount = Double(numericUsage), usageAmount > 0 else { return }

    let calculatedPrice: Double
    if draft.baseQuantity > 0 {
      calculatedPrice = (draft.basePrice / draft.baseQuantity) * usageAmount
    } else {
      calculatedPrice = 0
    }

    let ingredient = IngredientItem(
      ingredientId: draft.ingredientId,
      name: draft.name,
      amount: "\(formatAmount(usageAmount))\(IngredientUnit.from(draft.unitCode).title)",
      price: formatPrice(calculatedPrice)
    )
    onAdd(ingredient)
    dismiss()
  }

  private func presentCustomIngredientDraft() {
    let name = ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return }
    registeredIngredientDraft = nil
    isUnitDropdownExpanded = false
    customIngredientDraft = CustomIngredientDraft(
      name: name,
      category: "식재료",
      price: "",
      purchaseAmount: "",
      usageAmount: "",
      supplier: "",
      unit: .g
    )
  }

  private func confirmCustomIngredientAdd() {
    guard let draft = customIngredientDraft else { return }
    let usageAmount = parseNumeric(from: draft.usageAmount)
    let purchaseAmount = parseNumeric(from: draft.purchaseAmount)
    let price = parseNumeric(from: draft.price)
    guard price > 0, purchaseAmount > 0, usageAmount > 0 else { return }

    let unitCost = purchaseAmount > 0 ? (price / purchaseAmount) * usageAmount : 0

    let ingredient = IngredientItem(
      name: draft.name,
      amount: "\(formatAmount(usageAmount))\(draft.unit.title)",
      price: formatPrice(unitCost)
    )
    onAdd(ingredient)
    dismiss()
  }

  private func parseAmountAndUnit(from text: String) -> (amount: Double, unit: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let numeric = trimmed.filter { $0.isNumber || $0 == "." || $0 == "," }.replacingOccurrences(of: ",", with: "")
    let value = Double(numeric) ?? 0
    let unit = String(trimmed.filter { !$0.isNumber && $0 != "." && $0 != "," })
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return (value, IngredientUnit.from(unit).title)
  }

  private func sanitizeDigitsAndCommas(_ value: String) -> String {
    value.filter { $0.isNumber || $0 == "," }
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

  private func sanitizeDecimalsAndCommas(_ value: String) -> String {
    let filtered = value.filter { $0.isNumber || $0 == "." || $0 == "," }
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

  private func parsePrice(from text: String) -> Double {
    let numeric = text.filter { $0.isNumber || $0 == "." || $0 == "," }.replacingOccurrences(of: ",", with: "")
    return Double(numeric) ?? 0
  }

  private func parseNumeric(from text: String) -> Double {
    let numeric = text.filter { $0.isNumber || $0 == "." || $0 == "," }.replacingOccurrences(of: ",", with: "")
    return Double(numeric) ?? 0
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
    let unitCandidates = candidateUnits(for: unit)

    for candidate in unitCandidates {
      if trimmed.lowercased().hasSuffix(candidate.lowercased()) {
        return String(trimmed.dropLast(candidate.count)).trimmingCharacters(in: .whitespacesAndNewlines)
      }
    }

    return trimmed
  }

  private func appendUnitIfNeeded(to text: String, unit: String) -> String {
    let displayUnit = IngredientUnit.from(unit).title
    let raw = stripUnit(from: text, unit: unit)
      .filter { $0.isNumber || $0 == "." || $0 == "," }
    guard !raw.isEmpty else { return "" }

    let normalized = raw.replacingOccurrences(of: ",", with: "")
    if let value = Double(normalized) {
      let intValue = Int(value)
      if Double(intValue) == value {
        return "\(intValue)\(displayUnit)"
      }
      return "\(value)\(displayUnit)"
    }
    return "\(normalized)\(displayUnit)"
  }

  private func candidateUnits(for unit: String) -> [String] {
    let displayUnit = IngredientUnit.from(unit).title
    return Array(Set([unit, displayUnit].filter { !$0.isEmpty }))
  }

  private func isUsageEmpty(_ draft: RegisteredIngredientDraft) -> Bool {
    draft.usageAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func isCustomAddEnabled(_ draft: CustomIngredientDraft) -> Bool {
    let price = parseNumeric(from: draft.price)
    let purchaseAmount = parseNumeric(from: draft.purchaseAmount)
    let usageAmount = parseNumeric(from: draft.usageAmount)
    return price > 0 && purchaseAmount > 0 && usageAmount > 0
  }

  private func unitPriceText(_ draft: RegisteredIngredientDraft) -> String {
    if draft.baseQuantity > 0 {
      return "\(formatAmount(draft.baseQuantity))\(IngredientUnit.from(draft.unitCode).title)당 \(formatPrice(draft.basePrice))"
    }
    return "-"
  }
}

private struct RegisteredIngredientDraft: Equatable {
  let ingredientId: Int?
  let name: String
  let unitCode: String
  let baseQuantity: Double
  let basePrice: Double
  let supplier: String?
  var usageAmount: String
}

private struct CustomIngredientDraft: Equatable {
  let name: String
  var category: String
  var price: String
  var purchaseAmount: String
  var usageAmount: String
  var supplier: String
  var unit: IngredientUnit
}

private extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {
    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}

#Preview {
  AddIngredientSheet { _ in }
}
