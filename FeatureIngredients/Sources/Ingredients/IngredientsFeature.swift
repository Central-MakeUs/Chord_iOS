import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation
import UIKit

@Reducer
public struct IngredientsFeature {
  public struct State: Equatable {
    var selectedCategories: Set<String> = []
    var ingredients: [InventoryIngredientItem] = []
    var menuItems: [MenuItem] = []
    var categories: [IngredientCategoryResponse] = []
    var isLoading = false
    var error: String?
    var isManageMenuPresented = false
    var isDeleteMode = false
    var isDeleting = false
    var selectedForDeletion: Set<UUID> = []
    var showToast = false
    var toastMessage: String = ""
    var hasLoadedOnce = false
    var showAddIngredientSheet = false
    var addIngredientName = ""
    var showDupNameHint = false
    var showAddIngredientDetailSheet = false
    var addIngredientCategory = "식재료"
    var addIngredientPrice = ""
    var addIngredientAmount = ""
    var addIngredientSupplier = ""
    var addIngredientUnit: IngredientUnit = .g
    var isCreatingIngredient = false

    public init() {}

    public var isDeleteModeActive: Bool {
      isDeleteMode
    }
    
    public var filteredIngredients: [InventoryIngredientItem] {
      return ingredients
    }
    
    public var filterOptions: [String] {
      if categories.isEmpty {
        return ["즐겨찾기", "식재료", "운영 재료"]
      }
      return ["즐겨찾기"] + categories.sorted { $0.displayOrder < $1.displayOrder }.map { $0.categoryName }
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case refreshIngredients
    case searchChipTapped(String)
    case searchButtonTapped
    case ingredientsLoaded(Result<[InventoryIngredientItem], Error>)
    case menuItemsLoaded(Result<[MenuItem], Error>)
    case categoriesLoaded(Result<[IngredientCategoryResponse], Error>)
    case manageMenuTapped
    case manageMenuDismissed
    case addIngredientTapped
    case showAddIngredientSheetChanged(Bool)
    case addIngredientNameChanged(String)
    case addIngredientDupChecked(String, Bool)
    case addIngredientConfirmTapped
    case showAddIngredientDetailSheetChanged(Bool)
    case addIngredientCategorySelected(String)
    case addIngredientPriceChanged(String)
    case addIngredientAmountChanged(String)
    case addIngredientSupplierChanged(String)
    case addIngredientUnitSelected(IngredientUnit)
    case createIngredientTapped
    case createIngredientResponse(Result<IngredientResponse, Error>)
    case deleteModeTapped
    case ingredientSelectedForDeletion(UUID)
    case deleteButtonTapped
    case deleteFinished(Set<UUID>)
    case deleteCancelled
    case showToastChanged(Bool)
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case (.refreshIngredients, .refreshIngredients): return true
      case let (.searchChipTapped(l), .searchChipTapped(r)): return l == r
      case (.searchButtonTapped, .searchButtonTapped): return true
      case (.ingredientsLoaded(.success(let l)), .ingredientsLoaded(.success(let r))): return l == r
      case (.ingredientsLoaded(.failure), .ingredientsLoaded(.failure)): return true
      case (.menuItemsLoaded(.success(let l)), .menuItemsLoaded(.success(let r))): return l == r
      case (.menuItemsLoaded(.failure), .menuItemsLoaded(.failure)): return true
      case (.categoriesLoaded(.success(let l)), .categoriesLoaded(.success(let r))): return l == r
      case (.categoriesLoaded(.failure), .categoriesLoaded(.failure)): return true
      case (.manageMenuTapped, .manageMenuTapped): return true
      case (.manageMenuDismissed, .manageMenuDismissed): return true
      case (.addIngredientTapped, .addIngredientTapped): return true
      case let (.showAddIngredientSheetChanged(l), .showAddIngredientSheetChanged(r)): return l == r
      case let (.addIngredientNameChanged(l), .addIngredientNameChanged(r)): return l == r
      case let (.addIngredientDupChecked(lk, ld), .addIngredientDupChecked(rk, rd)): return lk == rk && ld == rd
      case (.addIngredientConfirmTapped, .addIngredientConfirmTapped): return true
      case let (.showAddIngredientDetailSheetChanged(l), .showAddIngredientDetailSheetChanged(r)): return l == r
      case let (.addIngredientCategorySelected(l), .addIngredientCategorySelected(r)): return l == r
      case let (.addIngredientPriceChanged(l), .addIngredientPriceChanged(r)): return l == r
      case let (.addIngredientAmountChanged(l), .addIngredientAmountChanged(r)): return l == r
      case let (.addIngredientSupplierChanged(l), .addIngredientSupplierChanged(r)): return l == r
      case let (.addIngredientUnitSelected(l), .addIngredientUnitSelected(r)): return l == r
      case (.createIngredientTapped, .createIngredientTapped): return true
      case (.createIngredientResponse(.success(let l)), .createIngredientResponse(.success(let r))): return l == r
      case (.createIngredientResponse(.failure), .createIngredientResponse(.failure)): return true
      case (.deleteModeTapped, .deleteModeTapped): return true
      case let (.ingredientSelectedForDeletion(l), .ingredientSelectedForDeletion(r)): return l == r
      case (.deleteButtonTapped, .deleteButtonTapped): return true
      case let (.deleteFinished(l), .deleteFinished(r)): return l == r
      case (.deleteCancelled, .deleteCancelled): return true
      case let (.showToastChanged(l), .showToastChanged(r)): return l == r
      default: return false
      }
    }
  }

  public init() {}
  
  @Dependency(\.ingredientRepository) var ingredientRepository
  @Dependency(\.menuRepository) var menuRepository

  private enum CancelID {
    case delete
    case checkDupName
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.ingredients.isEmpty && !state.isLoading else { return .none }
        state.isLoading = true
        
        return .merge(
          .run { send in
            let result = await Result { try await ingredientRepository.fetchIngredients(nil) }
            await send(.ingredientsLoaded(result))
          },
          .run { send in
            let result = await Result { try await menuRepository.fetchMenuItems(nil) }
            await send(.menuItemsLoaded(result))
          },
          .run { send in
            let result = await Result { try await ingredientRepository.fetchIngredientCategories() }
            await send(.categoriesLoaded(result))
          }
        )
        
      case .refreshIngredients:
        guard !state.isLoading else { return .none }
        state.isLoading = true
        let selected = state.selectedCategories
        
        if selected.isEmpty {
          return .run { send in
            let result = await Result { try await ingredientRepository.fetchIngredients(nil) }
            await send(.ingredientsLoaded(result))
          }
        }
        
        return .run { [categories = state.categories, selected] send in
          var categoryCodes: [String] = []
          
          for categoryName in selected {
            if categoryName == "즐겨찾기" {
              categoryCodes.append("FAVORITE")
            } else if let category = categories.first(where: { $0.categoryName == categoryName }) {
              categoryCodes.append(category.categoryCode)
            } else {
              switch categoryName {
              case "식재료": categoryCodes.append("INGREDIENTS")
              case "운영 재료": categoryCodes.append("MATERIALS")
              default: break
              }
            }
          }
          
          let result = await Result {
            try await ingredientRepository.fetchIngredients(categoryCodes.isEmpty ? nil : categoryCodes)
          }
          await send(.ingredientsLoaded(result))
        }
        
      case let .ingredientsLoaded(.success(items)):
        state.ingredients = items
        state.isLoading = false
        state.error = nil
        state.hasLoadedOnce = true
        return .none
        
      case let .ingredientsLoaded(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
        
      case let .menuItemsLoaded(.success(items)):
        state.menuItems = items
        return .none
        
      case let .menuItemsLoaded(.failure(error)):
        state.error = error.localizedDescription
        return .none
        
      case let .categoriesLoaded(.success(categories)):
        state.categories = categories
        return .none
        
      case let .categoriesLoaded(.failure(error)):
        print("Failed to load categories: \(error)")
        return .none
        
      case let .searchChipTapped(keyword):
        let hapticEffect = selectionHaptic()
        if state.selectedCategories.contains(keyword) {
          state.selectedCategories.remove(keyword)
        } else {
          state.selectedCategories.insert(keyword)
        }
        
        let selected = state.selectedCategories
        if selected.isEmpty {
          state.isLoading = true
          return .merge(
            hapticEffect,
            .run { send in
              let result = await Result { try await ingredientRepository.fetchIngredients(nil) }
              await send(.ingredientsLoaded(result))
            }
          )
        }
        
        state.isLoading = true
        return .merge(
          hapticEffect,
          .run { [categories = state.categories, selected] send in
            var categoryCodes: [String] = []

            for categoryName in selected {
              if categoryName == "즐겨찾기" {
                categoryCodes.append("FAVORITE")
              } else if let category = categories.first(where: { $0.categoryName == categoryName }) {
                categoryCodes.append(category.categoryCode)
              } else {
                switch categoryName {
                case "식재료": categoryCodes.append("INGREDIENTS")
                case "운영 재료": categoryCodes.append("MATERIALS")
                default: break
                }
              }
            }

            let result = await Result {
              try await ingredientRepository.fetchIngredients(categoryCodes.isEmpty ? nil : categoryCodes)
            }
            await send(.ingredientsLoaded(result))
          }
        )
        
      case .searchButtonTapped:
        return .none
        
      case .manageMenuTapped:
        state.isManageMenuPresented = true
        return .none
        
      case .manageMenuDismissed:
        state.isManageMenuPresented = false
        return .none
        
      case .addIngredientTapped:
        state.isManageMenuPresented = false
        state.showAddIngredientSheet = true
        state.addIngredientName = ""
        state.showDupNameHint = false
        return .cancel(id: CancelID.checkDupName)

      case let .showAddIngredientSheetChanged(isPresented):
        state.showAddIngredientSheet = isPresented
        if !isPresented {
          state.addIngredientName = ""
          state.showDupNameHint = false
          return .cancel(id: CancelID.checkDupName)
        }
        return .none

      case let .addIngredientNameChanged(name):
        state.addIngredientName = name
        state.showDupNameHint = false

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
          return .cancel(id: CancelID.checkDupName)
        }

        return .run { [trimmed] send in
          try await Task.sleep(for: .milliseconds(350))
          let isDup = (try? await ingredientRepository.checkDupName(trimmed)) ?? false
          await send(.addIngredientDupChecked(trimmed, isDup))
        }
        .cancellable(id: CancelID.checkDupName, cancelInFlight: true)

      case let .addIngredientDupChecked(keyword, isDup):
        guard keyword == state.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines) else {
          return .none
        }
        state.showDupNameHint = isDup
        return .none

      case .addIngredientConfirmTapped:
        guard !state.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          return .none
        }
        state.showAddIngredientSheet = false
        state.showAddIngredientDetailSheet = true
        state.addIngredientCategory = "식재료"
        state.addIngredientPrice = ""
        state.addIngredientAmount = ""
        state.addIngredientSupplier = ""
        state.addIngredientUnit = .g
        state.showDupNameHint = false
        return .none

      case let .showAddIngredientDetailSheetChanged(isPresented):
        state.showAddIngredientDetailSheet = isPresented
        if !isPresented {
          state.addIngredientName = ""
          state.addIngredientPrice = ""
          state.addIngredientAmount = ""
          state.addIngredientSupplier = ""
          state.addIngredientCategory = "식재료"
          state.addIngredientUnit = .g
          state.isCreatingIngredient = false
        }
        return .none

      case let .addIngredientCategorySelected(category):
        state.addIngredientCategory = category
        return selectionHaptic()

      case let .addIngredientPriceChanged(price):
        state.addIngredientPrice = price
        return .none

      case let .addIngredientAmountChanged(amount):
        state.addIngredientAmount = amount
        return .none

      case let .addIngredientSupplierChanged(supplier):
        state.addIngredientSupplier = supplier
        return .none

      case let .addIngredientUnitSelected(unit):
        state.addIngredientUnit = unit
        return .none

      case .createIngredientTapped:
        guard !state.isCreatingIngredient else { return .none }
        let name = state.addIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        let priceText = state.addIngredientPrice.replacingOccurrences(of: ",", with: "")
        let amountText = state.addIngredientAmount.replacingOccurrences(of: ",", with: "")
        guard
          !name.isEmpty,
          let price = Double(priceText), price > 0,
          let amount = Double(amountText), amount > 0
        else {
          return .none
        }

        state.isCreatingIngredient = true
        let categoryCode = state.addIngredientCategory == "운영 재료" ? "MATERIALS" : "INGREDIENTS"
        let unitCode = state.addIngredientUnit.serverCode
        let supplier = state.addIngredientSupplier.trimmingCharacters(in: .whitespacesAndNewlines)

        return .run { send in
          let request = IngredientCreateRequest(
            categoryCode: categoryCode,
            ingredientName: name,
            unitCode: unitCode,
            price: price,
            amount: amount,
            supplier: supplier.isEmpty ? nil : supplier
          )
          let result = await Result { try await ingredientRepository.createIngredient(request) }
          await send(.createIngredientResponse(result))
        }

      case .createIngredientResponse(.success):
        state.isCreatingIngredient = false
        state.showAddIngredientDetailSheet = false
        state.showToast = true
        state.toastMessage = "재료가 추가됐어요"
        return .send(.refreshIngredients)

      case let .createIngredientResponse(.failure(error)):
        state.isCreatingIngredient = false
        if let apiError = error as? APIError, !apiError.message.isEmpty {
          state.toastMessage = apiError.message
        } else {
          state.toastMessage = "재료 추가에 실패했어요"
        }
        state.showToast = true
        return .none
        
      case .deleteModeTapped:
        state.isManageMenuPresented = false
        state.isDeleteMode = true
        return .none
        
      case let .ingredientSelectedForDeletion(id):
        if state.selectedForDeletion.contains(id) {
          state.selectedForDeletion.remove(id)
        } else {
          state.selectedForDeletion.insert(id)
        }
        return .none
        
      case .deleteButtonTapped:
        guard !state.isDeleting else { return .none }

        let selectedIds = state.selectedForDeletion
        let selectedItems = state.ingredients.filter { selectedIds.contains($0.id) }
        guard !selectedItems.isEmpty else { return .none }

        state.isDeleting = true

        return .run { [ingredientRepository, selectedItems] send in
          var deletedIds = Set<UUID>()
          for item in selectedItems {
            guard let apiId = item.apiId else {
              deletedIds.insert(item.id)
              continue
            }

            do {
              try await ingredientRepository.deleteIngredient(apiId)
              deletedIds.insert(item.id)
            } catch {
              // Ignore failures; keep item in list.
            }
          }

          await send(.deleteFinished(deletedIds))
        }
        .cancellable(id: CancelID.delete, cancelInFlight: true)

      case let .deleteFinished(deletedIds):
        state.isDeleting = false
        state.ingredients.removeAll { deletedIds.contains($0.id) }
        state.selectedForDeletion.removeAll()
        state.isDeleteMode = false

        let count = deletedIds.count
        if count > 0 {
          state.toastMessage = "\(count)개의 재료가 삭제됐어요"
          state.showToast = true
        }
        return .send(.refreshIngredients)
        
      case .deleteCancelled:
        state.isDeleting = false
        state.selectedForDeletion.removeAll()
        state.isDeleteMode = false
        return .cancel(id: CancelID.delete)

      case let .showToastChanged(isPresented):
        state.showToast = isPresented
        return .none
      }
    }
  }

  private func selectionHaptic() -> Effect<Action> {
    .run { _ in
      await MainActor.run {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
      }
    }
  }
}
