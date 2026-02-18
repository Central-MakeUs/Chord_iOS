import SwiftUI
import ComposableArchitecture
import CoreModels
import DesignSystem

public struct IngredientsView: View {
    let store: StoreOf<IngredientsFeature>
    @FocusState private var isAddNameFocused: Bool
    @State private var isAddUnitDropdownExpanded = false
    
    public init(store: StoreOf<IngredientsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let totalCount = viewStore.filteredIngredients.count
            let selectedCount = viewStore.selectedForDeletion.count
            
            ZStack {
                AppColor.grayscale200
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    header(totalCount: totalCount, isDeleteMode: viewStore.isDeleteMode, viewStore: viewStore)
                        .padding(.horizontal, 20)
                    
                    filterChips(
                        options: viewStore.filterOptions,
                        selected: viewStore.selectedCategories,
                        onSelect: { viewStore.send(.searchChipTapped($0)) }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    ScrollView {
                        ingredientList(
                            items: viewStore.filteredIngredients,
                            isDeleteMode: viewStore.isDeleteMode,
                            selectedIds: viewStore.selectedForDeletion,
                            onSelect: { viewStore.send(.ingredientSelectedForDeletion($0)) }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color.white
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 24,
                                    topTrailingRadius: 24
                                )
                            )
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                if viewStore.hasLoadedOnce {
                    viewStore.send(.refreshIngredients)
                } else {
                    viewStore.send(.onAppear)
                }
            }
            .overlay(alignment: .topTrailing) {
                if viewStore.isManageMenuPresented && !viewStore.isDeleteMode {
                    ZStack(alignment: .topTrailing) {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewStore.send(.manageMenuDismissed)
                            }
                        
                        manageMenuOverlay(viewStore: viewStore)
                            .frame(width: 76, height: 80)
                            .padding(.top, 44)
                            .padding(.trailing, 20)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if viewStore.isDeleteMode {
                    deleteBottomBar(
                        selectedCount: selectedCount,
                        isDeleting: viewStore.isDeleting,
                        onDelete: { viewStore.send(.deleteButtonTapped) }
                    )
                }
            }
            .toastBanner(
                isPresented: viewStore.binding(
                    get: \.showToast,
                    send: IngredientsFeature.Action.showToastChanged
                ),
                message: viewStore.toastMessage,
                duration: 1.0
            )
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showAddIngredientSheet,
                    send: IngredientsFeature.Action.showAddIngredientSheetChanged
                )
            ) {
                addIngredientSheet(viewStore: viewStore)
                    .presentationDetents([.height(280)])
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(Color.white)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.showAddIngredientDetailSheet,
                    send: IngredientsFeature.Action.showAddIngredientDetailSheetChanged
                )
            ) {
                addIngredientDetailSheet(viewStore: viewStore)
                    .presentationDetents([.large])
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(Color.white)
            }
            .toolbar(viewStore.isDeleteMode ? .hidden : .visible , for: .tabBar)

        }
    }
    
    private func header(
        totalCount: Int,
        isDeleteMode: Bool,
        viewStore: ViewStoreOf<IngredientsFeature>
    ) -> some View {
        HStack(spacing: 16) {
            if isDeleteMode {
                Button(action: { viewStore.send(.deleteCancelled) }) {
                    Image.arrowLeftIcon
                        .renderingMode(.template)
                        .foregroundColor(AppColor.grayscale900)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 4) {
                Text("재료")
                    .font(.pretendardHeadline2)
                    .foregroundColor(AppColor.grayscale900)
                Text("\(totalCount)")
                    .font(.pretendardHeadline2)
                    .foregroundColor(AppColor.primaryBlue500)
            }
            
            Spacer()
            
            if !isDeleteMode {
                Button(action: {
                    viewStore.send(.searchButtonTapped)
                }) {
                    Image.searchIcon
                        .frame(width: 24, height: 24)
                }
                Button(action: { viewStore.send(.manageMenuTapped) }) {
                    Image.meatballIcon
                        .frame(width: 24, height: 24)
                }
            }
        }
        .frame(height: 56)
    }
    
    private func manageMenuOverlay(viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Button(action: { viewStore.send(.addIngredientTapped) }) {
                Text("추가")
                    .font(.pretendardBody3)
                    .foregroundColor(AppColor.grayscale900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 40)
            .buttonStyle(.plain)
            
            Divider()
                .background(AppColor.grayscale200)
            
            Button(action: { viewStore.send(.deleteModeTapped) }) {
                Text("삭제")
                    .font(.pretendardBody3)
                    .foregroundColor(AppColor.semanticWarningText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 40)
            .buttonStyle(.plain)
        }
        .frame(width: 76, height: 80)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    private func addIngredientSheet(viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("추가하실 재료명을 입력해주세요")
                .font(.pretendardHeadline2)
                .foregroundColor(AppColor.grayscale900)
                .padding(.bottom, 20)
                .padding(.top, 40)

            Text("재료명")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale900)
                .padding(.bottom, 8)


            TextField(
                "",
                text: viewStore.binding(
                    get: \.addIngredientName,
                    send: IngredientsFeature.Action.addIngredientNameChanged
                ),
                prompt: Text("재료명 입력")
                    .font(.pretendardSubtitle2)
                    .foregroundColor(AppColor.grayscale500)
            )
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .focused($isAddNameFocused)
            .padding(.top, 8)

            Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
                .padding(.top, 8)

            if viewStore.showDupNameHint {
                duplicateNameHint
                    .padding(.top, 4)
            }

            Spacer(minLength: 20)

            BottomButton(
                title: "확인",
                style: viewStore.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .primary
            ) {
                viewStore.send(.addIngredientConfirmTapped)
            }
            .disabled(viewStore.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
        .background(Color.white.ignoresSafeArea())
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isAddNameFocused = false
            }
        )
    }
    
    private var duplicateNameHint: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Image.speechBubbleTail
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 14)
                    .foregroundColor(AppColor.grayscale800)
                    .padding(.leading, 28)
                    .padding(.bottom, -2)
                
                Text("동일한 재료명이 존재해요\n이대로 진행할까요?")
                    .font(.pretendardSubtitle2)
                    .foregroundColor(Color.white)
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColor.grayscale800)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private func addIngredientDetailSheet(viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
        VStack(spacing: 12) {
            SheetDragHandle()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewStore.addIngredientName)
                            .font(.pretendardHeadline2)
                            .foregroundColor(AppColor.grayscale900)
                        
                        HStack(spacing: 8) {
                            detailCategoryTab(
                                label: "식재료",
                                isSelected: viewStore.addIngredientCategory == "식재료"
                            ) {
                                viewStore.send(.addIngredientCategorySelected("식재료"))
                            }
                            
                            detailCategoryTab(
                                label: "운영 재료",
                                isSelected: viewStore.addIngredientCategory == "운영 재료"
                            ) {
                                viewStore.send(.addIngredientCategorySelected("운영 재료"))
                            }
                            
                            Spacer()
                        }
                    }
                    
                    detailUnderlinedField(
                        title: "가격",
                        placeholder: "구매한 가격 입력",
                        text: viewStore.binding(
                            get: \.addIngredientPrice,
                            send: IngredientsFeature.Action.addIngredientPriceChanged
                        ),
                        keyboardType: .numberPad
                    )
                    
                    detailAmountField(viewStore: viewStore)
                    
                    detailUnderlinedField(
                        title: "공급업체 (선택)",
                        placeholder: "공급업체명 입력",
                        text: viewStore.binding(
                            get: \.addIngredientSupplier,
                            send: IngredientsFeature.Action.addIngredientSupplierChanged
                        ),
                        keyboardType: .default
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            let trimmedName = viewStore.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedPrice = viewStore.addIngredientPrice.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedAmount = viewStore.addIngredientAmount.trimmingCharacters(in: .whitespacesAndNewlines)
            let isEnabled = !trimmedName.isEmpty && !trimmedPrice.isEmpty && !trimmedAmount.isEmpty && !viewStore.isCreatingIngredient
            
            BottomButton(title: "재료 추가", style: isEnabled ? .primary : .secondary) {
                viewStore.send(.createIngredientTapped)
            }
            .disabled(!isEnabled)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 34)
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isAddNameFocused = false
            }
        )
    }
    
    private func detailCategoryTab(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.pretendardCaption1)
                .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale600)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? AppColor.primaryBlue100 : AppColor.grayscale200)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func detailUnderlinedField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale900)
            
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .font(.pretendardSubtitle2)
                    .foregroundColor(AppColor.grayscale500)
            )
            .font(.pretendardSubtitle2)
            .foregroundColor(AppColor.grayscale900)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            
            Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
        }
    }
    
    private func detailAmountField(viewStore: ViewStoreOf<IngredientsFeature>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("용량")
                .font(.pretendardCaption1)
                .foregroundColor(AppColor.grayscale900)
            
            HStack(spacing: 8) {
                TextField(
                    "",
                    text: viewStore.binding(
                        get: \.addIngredientAmount,
                        send: IngredientsFeature.Action.addIngredientAmountChanged
                    ),
                    prompt: Text("구매량 용량 입력")
                        .font(.pretendardSubtitle2)
                        .foregroundColor(AppColor.grayscale500)
                )
                .font(.pretendardSubtitle2)
                .foregroundColor(AppColor.grayscale900)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                
                HStack(spacing: 8) {
                    Text("단위")
                        .font(.pretendardCaption1)
                        .foregroundColor(AppColor.grayscale500)
                    
                    Rectangle()
                        .fill(AppColor.grayscale300)
                        .frame(width: 1, height: 14)
                    
                    Button {
                        isAddUnitDropdownExpanded.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewStore.addIngredientUnit.title)
                                .font(.pretendardBody2)
                                .foregroundColor(AppColor.grayscale900)
                            Image.chevronDownOutlineIcon
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.grayscale900)
                                .rotationEffect(.degrees(isAddUnitDropdownExpanded ? 180 : 0))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Rectangle()
                .fill(AppColor.grayscale300)
                .frame(height: 1)
        }
        .overlay(alignment: .topTrailing) {
            if isAddUnitDropdownExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(IngredientUnit.allCases.enumerated()), id: \.element) { index, unit in
                        Button {
                            viewStore.send(.addIngredientUnitSelected(unit))
                            isAddUnitDropdownExpanded = false
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
        .zIndex(isAddUnitDropdownExpanded ? 1000 : 0)
        .animation(.easeInOut(duration: 0.15), value: isAddUnitDropdownExpanded)
    }
    
    private func filterChips(
        options: [String],
        selected: Set<String>,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { keyword in
                let isSelected = selected.contains(keyword)
                Button(action: {
                    onSelect(keyword)
                }) {
                    HStack(spacing: 4) {
                        Text(keyword)
                            .font(.pretendardBody2)
                            .foregroundColor(isSelected ? AppColor.primaryBlue500 : AppColor.grayscale600)
                        
                        if isSelected {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppColor.primaryBlue500)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? AppColor.primaryBlue200 : AppColor.grayscale300)
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    private func ingredientList(
        items: [InventoryIngredientItem],
        isDeleteMode: Bool,
        selectedIds: Set<UUID>,
        onSelect: @escaping (UUID) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, ingredient in
                if isDeleteMode {
                    Button(action: { onSelect(ingredient.id) }) {
                        IngredientRow(
                            item: ingredient,
                            isDeleteMode: true,
                            isSelected: selectedIds.contains(ingredient.id)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(value: IngredientsRoute.detail(ingredient)) {
                        IngredientRow(item: ingredient, isDeleteMode: false, isSelected: false)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            print(
                                "👉 [Ingredients] row tapped name=\(ingredient.name) apiId=\(String(describing: ingredient.apiId)) amount=\(ingredient.amount) price=\(ingredient.price)"
                            )
                        }
                    )
                }
                
                if index < items.count - 1 {
                    Divider()
                        .background(AppColor.grayscale200)
                }
            }
        }
    }
    
    private func deleteBottomBar(
        selectedCount: Int,
        isDeleting: Bool,
        onDelete: @escaping () -> Void
    ) -> some View {
        let title = selectedCount > 0 ? "\(selectedCount)개 삭제" : "삭제"
        let isEnabled = selectedCount > 0 && !isDeleting
        
        return VStack(spacing: 0) {
            Divider()
                .background(AppColor.grayscale200)
            
            BottomButton(
                title: title,
                height: 52,
                style: isEnabled ? .primary : .secondary
            ) {
                onDelete()
            }
            .disabled(!isEnabled)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .background(Color.white)
    }
}

private struct IngredientRow: View {
    let item: InventoryIngredientItem
    let isDeleteMode: Bool
    let isSelected: Bool
    
    private var displayAmount: String {
        let trimmed = item.amount.trimmingCharacters(in: .whitespacesAndNewlines)
        let numericPart = String(trimmed.prefix { $0.isNumber || $0 == "." || $0 == "," })
        let unitPart = String(trimmed.drop(while: { $0.isNumber || $0 == "." || $0 == "," }))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !unitPart.isEmpty else { return item.amount }
        return numericPart + IngredientUnit.from(unitPart).title
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if isDeleteMode {
                (isSelected ? Image.checkBoxCircleCheckedIcon : Image.checkBoxCircleIcon)
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.leading, 20)
            }
            
            Text(item.name)
                .font(.pretendardBody1)
                .foregroundColor(AppColor.grayscale900)
                .padding(.leading, isDeleteMode ? 0 : 20)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.price)
                    .font(.pretendardBody1)
                    .foregroundColor(AppColor.primaryBlue500)
                Text("\(displayAmount)당")
                    .font(.pretendardCaption2)
                    .foregroundColor(AppColor.grayscale600)
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    IngredientsView(
        store: Store(initialState: IngredientsFeature.State()) {
            IngredientsFeature()
        }
    )
    .environment(\.colorScheme, .light)
}
