import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation
import UIKit

@Reducer
public struct MenuRegistrationFeature {
  @Dependency(\.menuRepository) var menuRepository
  @Dependency(\.ingredientRepository) var ingredientRepository

  public enum Step: Equatable {
    case step1
    case step2
    case confirmation
  }

  public struct RegistrationIngredient: Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var amount: Double
    public var unitCode: String
    public var price: Double
    public var ingredientId: Int?
    public var isFromTemplate: Bool
    public var category: String?
    public var purchaseAmount: Double?
    public var purchasePrice: Double?
    public var supplier: String?

    public init(
      id: UUID = UUID(),
      name: String,
      amount: Double,
      unitCode: String,
      price: Double,
      ingredientId: Int? = nil,
      isFromTemplate: Bool = false,
      category: String? = nil,
      purchaseAmount: Double? = nil,
      purchasePrice: Double? = nil,
      supplier: String? = nil
    ) {
      self.id = id
      self.name = name
      self.amount = amount
      self.unitCode = unitCode
      self.price = price
      self.ingredientId = ingredientId
      self.isFromTemplate = isFromTemplate
      self.category = category
      self.purchaseAmount = purchaseAmount
      self.purchasePrice = purchasePrice
      self.supplier = supplier
    }

    public var formattedAmount: String {
      let intAmount = Int(amount)
      let displayUnit = IngredientUnit.from(unitCode).title
      if Double(intAmount) == amount {
        return "\(intAmount)\(displayUnit)"
      }
      return "\(amount)\(displayUnit)"
    }

    public var formattedPrice: String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      let intPrice = Int(price)
      if Double(intPrice) == price {
        return "\(formatter.string(from: NSNumber(value: intPrice)) ?? "\(intPrice)")원"
      }
      return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
    }
  }

  public struct RegisteredIngredientDraft: Equatable {
    public var ingredientId: Int
    public var name: String
    public var unitCode: String
    public var baseQuantity: Double
    public var basePrice: Double
    public var supplier: String?
    public var usageAmount: String

    public init(
      ingredientId: Int,
      name: String,
      unitCode: String,
      baseQuantity: Double,
      basePrice: Double,
      supplier: String?,
      usageAmount: String = ""
    ) {
      self.ingredientId = ingredientId
      self.name = name
      self.unitCode = unitCode
      self.baseQuantity = baseQuantity
      self.basePrice = basePrice
      self.supplier = supplier
      self.usageAmount = usageAmount
    }
  }

  public struct State: Equatable {
    public var currentStep: Step = .step1
    public var isNavigatingForward: Bool = true
    public var menuName: String = ""
    public var price: String = ""
    public var selectedCategory: String = "음료"
    public var workTimeMinutes: Int = 1
    public var workTimeSeconds: Int = 30

    public var searchResults: [SearchMenusResponse] = []
    public var isSearching: Bool = false
    public var showSuggestions: Bool = false

    public var templateId: Int?
    public var isTemplateApplied: Bool = false
    public var showTemplateAppliedBanner: Bool = false
    public var showTemplateSheet: Bool = false
    public var selectedTemplateName: String = ""

    public var addedIngredients: [RegistrationIngredient] = []
    public var templateIngredients: [RecipeTemplateResponse] = []
    public var ingredientInput: String = ""
    public var ingredientSearchResults: [SearchMyIngredientsResponse] = []
    public var isIngredientSearching: Bool = false
    public var showRegisteredIngredientSheet: Bool = false
    public var registeredIngredientDraft: RegisteredIngredientDraft?

    public var showIngredientDetailSheet: Bool = false
    public var selectedIngredientIndex: Int?
    public var isIngredientSelectionMode: Bool = false
    public var selectedIngredientIDs: Set<UUID> = []

    public var showIngredientAddSheet: Bool = false
    public var ingredientAddName: String = ""
    public var ingredientAddCategory: String = "식재료"
    public var ingredientAddPrice: String = ""
    public var ingredientAddPurchaseAmount: String = ""
    public var ingredientAddUsageAmount: String = ""
    public var ingredientAddSupplier: String = ""
    public var ingredientAddUnit: IngredientUnit = .g
    
    public var isToastPresented: Bool = false
    public var isTimePickerPresented: Bool = false

    public var isCreating: Bool = false
    public var isMenuCreated: Bool = false
    public var error: String?
    @PresentationState var alert: AlertState<Action.Alert>?
    
    public var isCheckingDup: Bool = false
    public var showDupMenuAlert: Bool = false
    public var showDupIngredientAlert: Bool = false
    public var dupIngredientNames: [String] = []
    public var showIngredientDupAlert: Bool = false
    public var pendingIngredientToAdd: RegistrationIngredient?

    public var workTimeText: String {
      if workTimeSeconds > 0 {
        return "\(workTimeMinutes)분 \(workTimeSeconds)초"
      }
      return "\(workTimeMinutes)분"
    }

    public var categoryCode: String {
      switch selectedCategory {
      case "음료": return "BEVERAGE"
      case "디저트": return "DESSERT"
      case "푸드": return "FOOD"
      default: return "BEVERAGE"
      }
    }

    public var totalIngredientCost: Double {
      addedIngredients.reduce(0) { $0 + $1.price }
    }

    public var formattedTotalCost: String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      let intCost = Int(totalIngredientCost)
      return "\(formatter.string(from: NSNumber(value: intCost)) ?? "\(intCost)")원"
    }

    public init() {}
  }

  public enum Action: Equatable {
    case menuNameChanged(String)
    case priceChanged(String)
    case categorySelected(String)
    case workTimeUpdated(minutes: Int, seconds: Int)
    case clearMenuNameTapped

    case searchMenusResponse(Result<[SearchMenusResponse], Error>)
    case templateSelected(SearchMenusResponse)
    case fetchTemplateResponse(Result<TemplateBasicResponse, Error>)
    case fetchTemplateIngredientsResponse(Result<[RecipeTemplateResponse], Error>)

    case showTemplateSheetChanged(Bool)
    case showTemplateAppliedBannerChanged(Bool)
    case applyTemplateTapped
    case cancelTemplateTapped
    case directInputTapped
    case dismissSuggestions

    case nextStepTapped
    case previousStepTapped
    case backTapped

    case _setNavigatingForward(Bool)
    case _setCurrentStep(Step)
    case _resetForAddMore

    case ingredientInputChanged(String)
    case ingredientSearchResponse(Result<[SearchMyIngredientsResponse], Error>)
    case ingredientSearchResultSelected(SearchMyIngredientsResponse)
    case ingredientSearchItemLoaded(InventoryIngredientItem)
    case ingredientSearchItemLoadFailed(SearchMyIngredientsResponse)
    case registeredIngredientUsageChanged(String)
    case showRegisteredIngredientSheetChanged(Bool)
    case confirmAddRegisteredIngredientTapped
    case addIngredientTapped
    case removeIngredient(UUID)
    case ingredientTapped(Int)
    case templateIngredientTapped(Int)
    case showIngredientDetailSheetChanged(Bool)
    case ingredientSelectionTapped
    case ingredientSelectionToggled(UUID)
    case deleteSelectedIngredientsTapped

    case showIngredientAddSheetChanged(Bool)
    case ingredientAddCategorySelected(String)
    case ingredientAddPriceChanged(String)
    case ingredientAddPurchaseAmountChanged(String)
    case ingredientAddUsageAmountChanged(String)
    case ingredientAddSupplierChanged(String)
    case ingredientAddUnitSelected(IngredientUnit)
    case confirmAddIngredientTapped
    
    case showToastChanged(Bool)
    case showTimePickerChanged(Bool)

    case completeTapped
    case addMoreTapped
    case finalCompleteTapped
    case menuCreatedHandled
    case createMenuResponse(Result<Void, Error>)
    case alert(PresentationAction<Alert>)
    
    case checkDupResponse(Result<CheckDupResponse, Error>)
    case dupMenuAlertConfirmed
    case dupMenuAlertCancelled
    case dupIngredientAlertConfirmed
    case dupIngredientAlertCancelled
    case ingredientDupCheckResponse(Result<Bool, Error>)
    case ingredientDupAlertConfirmed
    case ingredientDupAlertCancelled
    case proceedMenuCreation
    case proceedAddIngredient

    case delegate(Delegate)

    public enum Alert: Equatable {}

    public enum Delegate: Equatable {
      case menuCreated
      case dismissed
    }

    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case let (.menuNameChanged(l), .menuNameChanged(r)): return l == r
      case let (.priceChanged(l), .priceChanged(r)): return l == r
      case let (.categorySelected(l), .categorySelected(r)): return l == r
      case let (.workTimeUpdated(lm, ls), .workTimeUpdated(rm, rs)): return lm == rm && ls == rs
      case (.clearMenuNameTapped, .clearMenuNameTapped): return true
      case (.searchMenusResponse(.success(let l)), .searchMenusResponse(.success(let r))): return l == r
      case (.searchMenusResponse(.failure), .searchMenusResponse(.failure)): return true
      case let (.templateSelected(l), .templateSelected(r)): return l == r
      case (.fetchTemplateResponse(.success(let l)), .fetchTemplateResponse(.success(let r))): return l == r
      case (.fetchTemplateResponse(.failure), .fetchTemplateResponse(.failure)): return true
      case (.fetchTemplateIngredientsResponse(.success(let l)), .fetchTemplateIngredientsResponse(.success(let r))): return l == r
      case (.fetchTemplateIngredientsResponse(.failure), .fetchTemplateIngredientsResponse(.failure)): return true
      case let (.showTemplateSheetChanged(l), .showTemplateSheetChanged(r)): return l == r
      case let (.showTemplateAppliedBannerChanged(l), .showTemplateAppliedBannerChanged(r)): return l == r
      case (.applyTemplateTapped, .applyTemplateTapped): return true
      case (.cancelTemplateTapped, .cancelTemplateTapped): return true
      case (.directInputTapped, .directInputTapped): return true
      case (.dismissSuggestions, .dismissSuggestions): return true
      case (.nextStepTapped, .nextStepTapped): return true
      case (.previousStepTapped, .previousStepTapped): return true
      case (.backTapped, .backTapped): return true
      case let (._setNavigatingForward(l), ._setNavigatingForward(r)): return l == r
      case let (._setCurrentStep(l), ._setCurrentStep(r)): return l == r
      case (._resetForAddMore, ._resetForAddMore): return true
      case let (.ingredientInputChanged(l), .ingredientInputChanged(r)): return l == r
      case (.ingredientSearchResponse(.success(let l)), .ingredientSearchResponse(.success(let r))): return l == r
      case (.ingredientSearchResponse(.failure), .ingredientSearchResponse(.failure)): return true
      case let (.ingredientSearchResultSelected(l), .ingredientSearchResultSelected(r)): return l == r
      case let (.ingredientSearchItemLoaded(l), .ingredientSearchItemLoaded(r)): return l == r
      case let (.ingredientSearchItemLoadFailed(l), .ingredientSearchItemLoadFailed(r)): return l == r
      case let (.registeredIngredientUsageChanged(l), .registeredIngredientUsageChanged(r)): return l == r
      case let (.showRegisteredIngredientSheetChanged(l), .showRegisteredIngredientSheetChanged(r)): return l == r
      case (.confirmAddRegisteredIngredientTapped, .confirmAddRegisteredIngredientTapped): return true
      case (.addIngredientTapped, .addIngredientTapped): return true
      case let (.removeIngredient(l), .removeIngredient(r)): return l == r
      case let (.ingredientTapped(l), .ingredientTapped(r)): return l == r
      case let (.templateIngredientTapped(l), .templateIngredientTapped(r)): return l == r
      case let (.showIngredientDetailSheetChanged(l), .showIngredientDetailSheetChanged(r)): return l == r
      case (.ingredientSelectionTapped, .ingredientSelectionTapped): return true
      case let (.ingredientSelectionToggled(l), .ingredientSelectionToggled(r)): return l == r
      case (.deleteSelectedIngredientsTapped, .deleteSelectedIngredientsTapped): return true
      case let (.showIngredientAddSheetChanged(l), .showIngredientAddSheetChanged(r)): return l == r
      case let (.ingredientAddCategorySelected(l), .ingredientAddCategorySelected(r)): return l == r
      case let (.ingredientAddPriceChanged(l), .ingredientAddPriceChanged(r)): return l == r
      case let (.ingredientAddPurchaseAmountChanged(l), .ingredientAddPurchaseAmountChanged(r)): return l == r
      case let (.ingredientAddUsageAmountChanged(l), .ingredientAddUsageAmountChanged(r)): return l == r
      case let (.ingredientAddSupplierChanged(l), .ingredientAddSupplierChanged(r)): return l == r
      case let (.ingredientAddUnitSelected(l), .ingredientAddUnitSelected(r)): return l == r
      case (.confirmAddIngredientTapped, .confirmAddIngredientTapped): return true
      case let (.showToastChanged(l), .showToastChanged(r)): return l == r
      case let (.showTimePickerChanged(l), .showTimePickerChanged(r)): return l == r
      case (.completeTapped, .completeTapped): return true
      case (.addMoreTapped, .addMoreTapped): return true
      case (.finalCompleteTapped, .finalCompleteTapped): return true
      case (.menuCreatedHandled, .menuCreatedHandled): return true
      case (.createMenuResponse(.success), .createMenuResponse(.success)): return true
      case (.createMenuResponse(.failure), .createMenuResponse(.failure)): return true
      case (.alert, .alert): return true
      case (.checkDupResponse(.success(let l)), .checkDupResponse(.success(let r))): return l == r
      case (.checkDupResponse(.failure), .checkDupResponse(.failure)): return true
      case (.dupMenuAlertConfirmed, .dupMenuAlertConfirmed): return true
      case (.dupMenuAlertCancelled, .dupMenuAlertCancelled): return true
      case (.dupIngredientAlertConfirmed, .dupIngredientAlertConfirmed): return true
      case (.dupIngredientAlertCancelled, .dupIngredientAlertCancelled): return true
      case (.ingredientDupCheckResponse(.success(let l)), .ingredientDupCheckResponse(.success(let r))): return l == r
      case (.ingredientDupCheckResponse(.failure), .ingredientDupCheckResponse(.failure)): return true
      case (.ingredientDupAlertConfirmed, .ingredientDupAlertConfirmed): return true
      case (.ingredientDupAlertCancelled, .ingredientDupAlertCancelled): return true
      case (.proceedMenuCreation, .proceedMenuCreation): return true
      case (.proceedAddIngredient, .proceedAddIngredient): return true
      case let (.delegate(l), .delegate(r)): return l == r
      default: return false
      }
    }
  }

  public init() {}

  private enum CancelID {
    case menuSearch
    case ingredientSearch
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .menuNameChanged(name):
        let isNewInput = name != state.menuName
        state.menuName = name
        if name.isEmpty {
          state.showSuggestions = false
          state.searchResults = []
          state.isTemplateApplied = false
          state.showTemplateAppliedBanner = false
          state.templateId = nil
          return .cancel(id: CancelID.menuSearch)
        }
        if state.isTemplateApplied { return .none }
        guard isNewInput else { return .none }
        state.showSuggestions = true
        state.isSearching = true
        let keyword = name
        
        print("🔍 Searching for keyword: \(keyword)")
        
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          let result = await Result { try await menuRepository.searchMenus(keyword) }
          await send(.searchMenusResponse(result))
        }
        .cancellable(id: CancelID.menuSearch, cancelInFlight: true)

      case let .priceChanged(price):
        state.price = Self.sanitizedDigitsAndCommas(price)
        return .none

      case let .categorySelected(category):
        let shouldHaptic = state.selectedCategory != category
        state.selectedCategory = category
        return shouldHaptic ? selectionHaptic() : .none

      case let .workTimeUpdated(minutes, seconds):
        state.workTimeMinutes = minutes
        state.workTimeSeconds = seconds
        state.isTimePickerPresented = false
        return .none

      case .clearMenuNameTapped:
        state.menuName = ""
        state.isTemplateApplied = false
        state.showTemplateAppliedBanner = false
        state.showSuggestions = false
        state.searchResults = []
        state.templateId = nil
        state.price = ""
        state.addedIngredients = []
        state.templateIngredients = []
        return .cancel(id: CancelID.menuSearch)

      case let .searchMenusResponse(.success(results)):
        print("✅ Search success: Found \(results.count) items")
        state.searchResults = results
        state.isSearching = false
        return .none

      case let .searchMenusResponse(.failure(error)):
        print("❌ Search failed: \(error)")
        state.searchResults = []
        state.isSearching = false
        return .none

      case let .templateSelected(template):
        state.menuName = template.menuName
        state.selectedTemplateName = template.menuName
        state.templateId = template.templateId
        state.showTemplateSheet = true
        return .none

      case let .showTemplateSheetChanged(isPresented):
        state.showTemplateSheet = isPresented
        return .none

      case let .showTemplateAppliedBannerChanged(isPresented):
        state.showTemplateAppliedBanner = isPresented
        return .none

      case .applyTemplateTapped:
        state.showTemplateSheet = false
        state.showSuggestions = false
        state.isTemplateApplied = true
        state.showTemplateAppliedBanner = true
        guard let templateId = state.templateId else { return .none }
        return .merge(
          .run { send in
            let result = await Result { try await menuRepository.fetchTemplate(templateId) }
            await send(.fetchTemplateResponse(result))
          },
          .run { send in
            let result = await Result { try await menuRepository.fetchTemplateIngredients(templateId) }
            await send(.fetchTemplateIngredientsResponse(result))
          }
        )

      case .cancelTemplateTapped:
        state.showTemplateSheet = false
        state.showSuggestions = false
        state.templateId = nil
        return .none

      case .directInputTapped:
        state.showSuggestions = false
        state.isTemplateApplied = false
        state.templateId = nil
        return .none

      case let .fetchTemplateResponse(.success(template)):
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let intPrice = Int(template.defaultSellingPrice)
        state.price = formatter.string(from: NSNumber(value: intPrice)) ?? "\(intPrice)"
        state.selectedCategory = categoryNameFromCode(template.categoryCode)
        let totalSeconds = template.workTime
        state.workTimeMinutes = totalSeconds / 60
        state.workTimeSeconds = totalSeconds % 60
        return .none

      case .fetchTemplateResponse(.failure):
        state.error = "템플릿 정보를 불러올 수 없습니다"
        return .none

      case let .fetchTemplateIngredientsResponse(.success(ingredients)):
        print("✅ Template ingredients success: Found \(ingredients.count) items")
        state.templateIngredients = ingredients
        state.addedIngredients = ingredients.map { ingredient in
          RegistrationIngredient(
            name: ingredient.ingredientName,
            amount: ingredient.defaultUsageAmount,
            unitCode: ingredient.unitCode,
            price: ingredient.defaultPrice,
            isFromTemplate: true,
            category: ingredient.ingredientCategoryCode,
            purchaseAmount: ingredient.baseQuantity,
            purchasePrice: ingredient.unitPrice
          )
        }
        return .none

      case let .fetchTemplateIngredientsResponse(.failure(error)):
        print("❌ Template ingredients failed: \(error)")
        state.error = "템플릿 재료를 불러올 수 없습니다"
        return .none

      case .dismissSuggestions:
        state.showSuggestions = false
        return .none

      case .nextStepTapped:
        return .run { send in
          await send(._setNavigatingForward(true))
          await Task.yield()
          await send(._setCurrentStep(.step2))
        }

      case .previousStepTapped:
        switch state.currentStep {
        case .step1:
          return .send(.delegate(.dismissed))
        case .step2:
          state.isIngredientSelectionMode = false
          state.selectedIngredientIDs = []
          return .run { send in
            await send(._setNavigatingForward(false))
            await Task.yield()
            await send(._setCurrentStep(.step1))
          }
        case .confirmation:
          return .run { send in
            await send(._setNavigatingForward(false))
            await Task.yield()
            await send(._setCurrentStep(.step2))
          }
        }

      case .backTapped:
        return .send(.previousStepTapped)

      case let .ingredientInputChanged(input):
        state.ingredientInput = input

        let keyword = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
          state.ingredientSearchResults = []
          state.isIngredientSearching = false
          return .cancel(id: CancelID.ingredientSearch)
        }

        state.isIngredientSearching = true
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          let result = await Result { try await ingredientRepository.searchIngredientsInCatalog(keyword) }
          await send(.ingredientSearchResponse(result))
        }
        .cancellable(id: CancelID.ingredientSearch, cancelInFlight: true)

      case let .ingredientSearchResponse(.success(results)):
        state.isIngredientSearching = false
        state.ingredientSearchResults = results
        return .none

      case .ingredientSearchResponse(.failure):
        state.isIngredientSearching = false
        state.ingredientSearchResults = []
        return .none

      case let .ingredientSearchResultSelected(result):
        state.ingredientInput = result.ingredientName
        state.ingredientSearchResults = []
        state.isIngredientSearching = false
        return .run { [result] send in
          do {
            let item = try await ingredientRepository.fetchIngredientDetail(result.ingredientId)
            await send(.ingredientSearchItemLoaded(item))
          } catch {
            await send(.ingredientSearchItemLoadFailed(result))
          }
        }

      case let .ingredientSearchItemLoaded(item):
        let parsed = parseAmountAndUnit(from: item.amount)
        let basePrice = parsePrice(from: item.price)
        state.registeredIngredientDraft = RegisteredIngredientDraft(
          ingredientId: item.apiId ?? 0,
          name: item.name,
          unitCode: parsed.unit,
          baseQuantity: parsed.amount,
          basePrice: basePrice,
          supplier: item.supplier,
          usageAmount: ""
        )
        state.showRegisteredIngredientSheet = true
        return .none

      case .ingredientSearchItemLoadFailed:
        state.registeredIngredientDraft = nil
        state.showRegisteredIngredientSheet = false
        state.alert = AlertState {
          TextState("재료 정보를 불러오지 못했어요")
        } message: {
          TextState("잠시 후 다시 시도하거나, 직접 입력으로 재료를 추가해주세요.")
        }
        return .none

      case let .registeredIngredientUsageChanged(text):
        let unitCode = state.registeredIngredientDraft?.unitCode ?? ""
        state.registeredIngredientDraft?.usageAmount = Self.sanitizedUsageWithOptionalUnit(text, unit: unitCode)
        return .none

      case let .showRegisteredIngredientSheetChanged(isPresented):
        state.showRegisteredIngredientSheet = isPresented
        if !isPresented {
          state.registeredIngredientDraft = nil
        }
        return .none

      case .confirmAddRegisteredIngredientTapped:
        guard let draft = state.registeredIngredientDraft else { return .none }
        let numericUsage = draft.usageAmount
          .filter { $0.isNumber || $0 == "." || $0 == "," }
          .replacingOccurrences(of: ",", with: "")
        guard let usageAmount = Double(numericUsage), usageAmount > 0 else { return .none }

        let calculatedPrice: Double
        if draft.baseQuantity > 0 {
          calculatedPrice = (draft.basePrice / draft.baseQuantity) * usageAmount
        } else {
          calculatedPrice = 0
        }

        let ingredient = RegistrationIngredient(
          name: draft.name,
          amount: usageAmount,
          unitCode: draft.unitCode,
          price: calculatedPrice,
          ingredientId: draft.ingredientId,
          isFromTemplate: false,
          supplier: draft.supplier
        )

        state.addedIngredients.append(ingredient)
        state.ingredientInput = ""
        state.ingredientSearchResults = []
        state.isIngredientSearching = false
        state.showRegisteredIngredientSheet = false
        state.registeredIngredientDraft = nil
        state.isToastPresented = true
        return .none

      case .addIngredientTapped:
        let name = state.ingredientInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return .none }
        state.ingredientSearchResults = []
        state.isIngredientSearching = false
        state.ingredientAddName = name
        state.ingredientAddCategory = "식재료"
        state.ingredientAddPrice = ""
        state.ingredientAddPurchaseAmount = ""
        state.ingredientAddUsageAmount = ""
        state.ingredientAddSupplier = ""
        state.ingredientAddUnit = .g
        state.showIngredientAddSheet = true
        return .cancel(id: CancelID.ingredientSearch)

      case let .removeIngredient(id):
        state.addedIngredients.removeAll { $0.id == id }
        state.selectedIngredientIDs.remove(id)
        return .none

      case let .ingredientTapped(index):
        state.selectedIngredientIndex = index
        state.showIngredientDetailSheet = true
        return .none

      case let .templateIngredientTapped(index):
        state.selectedIngredientIndex = index
        state.showIngredientDetailSheet = true
        return .none

      case let .showIngredientDetailSheetChanged(isPresented):
        state.showIngredientDetailSheet = isPresented
        if !isPresented {
          state.selectedIngredientIndex = nil
        }
        return .none

      case .ingredientSelectionTapped:
        state.isIngredientSelectionMode.toggle()
        if !state.isIngredientSelectionMode {
          state.selectedIngredientIDs = []
        }
        return .none

      case let .ingredientSelectionToggled(id):
        guard state.isIngredientSelectionMode else { return .none }
        if state.selectedIngredientIDs.contains(id) {
          state.selectedIngredientIDs.remove(id)
        } else {
          state.selectedIngredientIDs.insert(id)
        }
        return .none

      case .deleteSelectedIngredientsTapped:
        guard !state.selectedIngredientIDs.isEmpty else { return .none }
        state.addedIngredients.removeAll { state.selectedIngredientIDs.contains($0.id) }
        state.selectedIngredientIDs = []
        state.isIngredientSelectionMode = false
        return .none

      case let .showIngredientAddSheetChanged(isPresented):
        state.showIngredientAddSheet = isPresented
        return .none

      case let .ingredientAddCategorySelected(category):
        let shouldHaptic = state.ingredientAddCategory != category
        state.ingredientAddCategory = category
        return shouldHaptic ? selectionHaptic() : .none

      case let .ingredientAddPriceChanged(price):
        state.ingredientAddPrice = Self.sanitizedDigitsAndCommas(price)
        return .none

      case let .ingredientAddPurchaseAmountChanged(amount):
        state.ingredientAddPurchaseAmount = Self.sanitizedDigitsAndCommas(amount)
        return .none

      case let .ingredientAddUsageAmountChanged(amount):
        state.ingredientAddUsageAmount = Self.sanitizedDigitsAndCommas(amount)
        return .none

      case let .ingredientAddSupplierChanged(supplier):
        state.ingredientAddSupplier = supplier
        return .none

      case let .ingredientAddUnitSelected(unit):
        state.ingredientAddUnit = unit
        return .none

      case .confirmAddIngredientTapped:
        let name = state.ingredientAddName
        guard !name.isEmpty else { return .none }
        let price = Double(state.ingredientAddPrice.replacingOccurrences(of: ",", with: "")) ?? 0
        let purchaseAmount = Double(state.ingredientAddPurchaseAmount.replacingOccurrences(of: ",", with: "")) ?? 0
        let usageAmount = Double(state.ingredientAddUsageAmount.replacingOccurrences(of: ",", with: "")) ?? 0
        guard price > 0, purchaseAmount > 0, usageAmount > 0 else { return .none }
        let unitCost = purchaseAmount > 0 ? (price / purchaseAmount) * usageAmount : 0

        let newIngredient = RegistrationIngredient(
          name: name,
          amount: usageAmount,
          unitCode: state.ingredientAddUnit.rawValue,
          price: unitCost,
          category: state.ingredientAddCategory,
          purchaseAmount: purchaseAmount,
          purchasePrice: price,
          supplier: state.ingredientAddSupplier.isEmpty ? nil : state.ingredientAddSupplier
        )
        state.pendingIngredientToAdd = newIngredient
        
        return .run { [name] send in
          let result = await Result { try await ingredientRepository.checkDupName(name) }
          await send(.ingredientDupCheckResponse(result))
        }
      
      case let .ingredientDupCheckResponse(.success(isDuplicate)):
        if isDuplicate {
          state.showIngredientDupAlert = true
          return .none
        }
        return .send(.proceedAddIngredient)
      
      case .ingredientDupCheckResponse(.failure):
        return .send(.proceedAddIngredient)
      
      case .ingredientDupAlertConfirmed:
        state.showIngredientDupAlert = false
        return .send(.proceedAddIngredient)
      
      case .ingredientDupAlertCancelled:
        state.showIngredientDupAlert = false
        state.pendingIngredientToAdd = nil
        return .none
      
      case .proceedAddIngredient:
        guard let ingredient = state.pendingIngredientToAdd else { return .none }
        state.addedIngredients.append(ingredient)
        state.ingredientInput = ""
        state.ingredientSearchResults = []
        state.isIngredientSearching = false
        state.showIngredientAddSheet = false
        state.isToastPresented = true
        state.pendingIngredientToAdd = nil
        return .none
        
      case let .showToastChanged(isPresented):
        state.isToastPresented = isPresented
        return .none
        
      case let .showTimePickerChanged(isPresented):
        state.isTimePickerPresented = isPresented
        return .none

      case .completeTapped:
        return .run { send in
          await send(._setNavigatingForward(true))
          await Task.yield()
          await send(._setCurrentStep(.confirmation))
        }

      case .addMoreTapped:
        return .run { send in
          await send(._setNavigatingForward(false))
          await Task.yield()
          await send(._resetForAddMore)
        }

      case let ._setNavigatingForward(isForward):
        state.isNavigatingForward = isForward
        return .none

      case let ._setCurrentStep(step):
        state.currentStep = step
        return .none

      case ._resetForAddMore:
        state.menuName = ""
        state.price = ""
        state.selectedCategory = "음료"
        state.workTimeMinutes = 1
        state.workTimeSeconds = 30
        state.searchResults = []
        state.isSearching = false
        state.showSuggestions = false
        state.templateId = nil
        state.isTemplateApplied = false
        state.showTemplateSheet = false
        state.selectedTemplateName = ""
        state.addedIngredients = []
        state.templateIngredients = []
        state.ingredientInput = ""
        state.ingredientSearchResults = []
        state.isIngredientSearching = false
        state.showRegisteredIngredientSheet = false
        state.registeredIngredientDraft = nil
        state.isIngredientSelectionMode = false
        state.selectedIngredientIDs = []
        state.currentStep = .step1
        return .none

      case .finalCompleteTapped:
        let newIngredientNames = state.addedIngredients
          .filter { $0.ingredientId == nil }
          .map { $0.name }
        
        let request = CheckDupRequest(
          menuName: state.menuName,
          ingredientNames: newIngredientNames.isEmpty ? nil : newIngredientNames
        )
        
        state.isCheckingDup = true
        return .run { send in
          let result = await Result { try await menuRepository.checkDupNames(request) }
          await send(.checkDupResponse(result))
        }

      case .menuCreatedHandled:
        state.isMenuCreated = false
        return .none
      
      case let .checkDupResponse(.success(response)):
        state.isCheckingDup = false
        state.dupIngredientNames = response.dupIngredientNames ?? []
        
        if response.menuNameDuplicate {
          state.showDupMenuAlert = true
          return .none
        }
        
        if !state.dupIngredientNames.isEmpty {
          state.showDupIngredientAlert = true
          return .none
        }
        
        return .send(.proceedMenuCreation)
      
      case .checkDupResponse(.failure):
        state.isCheckingDup = false
        return .send(.proceedMenuCreation)
      
      case .dupMenuAlertConfirmed:
        state.showDupMenuAlert = false
        if !state.dupIngredientNames.isEmpty {
          state.showDupIngredientAlert = true
          return .none
        }
        return .send(.proceedMenuCreation)
      
      case .dupMenuAlertCancelled:
        state.showDupMenuAlert = false
        return .none
      
      case .dupIngredientAlertConfirmed:
        state.showDupIngredientAlert = false
        return .send(.proceedMenuCreation)
      
      case .dupIngredientAlertCancelled:
        state.showDupIngredientAlert = false
        state.dupIngredientNames = []
        return .none
      
      case .proceedMenuCreation:
        let numericPrice = state.price.replacingOccurrences(of: ",", with: "")
        guard let sellingPrice = Double(numericPrice) else { return .none }
        let totalSeconds = state.workTimeMinutes * 60 + state.workTimeSeconds

        let recipes: [RecipeCreateRequest] = state.addedIngredients.compactMap { ingredient in
          guard let ingredientId = ingredient.ingredientId else { return nil }
          return RecipeCreateRequest(ingredientId: ingredientId, amount: ingredient.amount)
        }

        let newRecipes: [NewRecipeCreateRequest] = state.addedIngredients.compactMap { ingredient in
          guard ingredient.ingredientId == nil else { return nil }
          let unitCode = IngredientUnit.from(ingredient.unitCode).serverCode
          let categoryCode = ingredientCategoryCode(from: ingredient.category)

          let purchaseAmount = ingredient.purchaseAmount ?? ingredient.amount
          let purchasePrice = ingredient.purchasePrice ?? ingredient.price
          let usageAmount = ingredient.amount
          
          return NewRecipeCreateRequest(
            amount: purchaseAmount,
            usageAmount: usageAmount,
            price: purchasePrice,
            unitCode: unitCode,
            ingredientCategoryCode: categoryCode,
            ingredientName: ingredient.name,
            supplier: ingredient.supplier
          )
        }

        let menuRequest = MenuCreateRequest(
          menuCategoryCode: state.categoryCode,
          menuName: state.menuName,
          sellingPrice: sellingPrice,
          workTime: totalSeconds,
          recipes: recipes,
          newRecipes: newRecipes
        )

        state.isCreating = true
        return .run { send in
          let result = await Result { try await menuRepository.createMenu(menuRequest) }
          await send(.createMenuResponse(result))
        }

      case .createMenuResponse(.success):
        print("✅ Menu Created Successfully")
        state.isCreating = false
        state.isMenuCreated = true
        return .send(.delegate(.menuCreated))

      case let .createMenuResponse(.failure(error)):
        print("❌ Menu Creation Failed: \(error)")
        state.isCreating = false
        state.alert = AlertState { TextState("메뉴 생성 실패") } message: { TextState(error.localizedDescription) }
        return .none

      case .alert:
        return .none

      case .delegate:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
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

private extension MenuRegistrationFeature {
  static func sanitizedDigitsAndCommas(_ value: String) -> String {
    value.filter { $0.isNumber || $0 == "," }
  }

  static func sanitizedDecimalsAndCommas(_ value: String) -> String {
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

  static func sanitizedUsageWithOptionalUnit(_ value: String, unit: String) -> String {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "" }

    let hasUnitSuffix = !unit.isEmpty && trimmed.hasSuffix(unit)
    let numericSource = hasUnitSuffix ? String(trimmed.dropLast(unit.count)) : trimmed
    let sanitizedNumeric = sanitizedDecimalsAndCommas(numericSource)

    guard !sanitizedNumeric.isEmpty else { return "" }
    return hasUnitSuffix ? sanitizedNumeric + unit : sanitizedNumeric
  }

  func categoryNameFromCode(_ code: String) -> String {
    switch code {
    case "BEVERAGE": return "음료"
    case "DESSERT": return "디저트"
    case "FOOD": return "푸드"
    default: return "음료"
    }
  }
  
  func ingredientCategoryCode(from category: String?) -> String {
    switch category {
    case "식재료", "INGREDIENTS": return "INGREDIENTS"
    case "운영 재료", "MATERIALS": return "MATERIALS"
    default: return "INGREDIENTS"
    }
  }

  func parseAmountAndUnit(from amountText: String) -> (amount: Double, unit: String) {
    let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
    let numericPart = String(trimmed.prefix { $0.isNumber || $0 == "." || $0 == "," })
      .replacingOccurrences(of: ",", with: "")
    let unitPart = String(trimmed.drop(while: { $0.isNumber || $0 == "." || $0 == "," })).trimmingCharacters(in: .whitespaces)

    let amount = Double(numericPart) ?? 0
    let unit = IngredientUnit.from(unitPart).title
    return (amount, unit)
  }

  func parsePrice(from priceText: String) -> Double {
    let filtered = priceText.filter { $0.isNumber || $0 == "." }
    return Double(filtered) ?? 0
  }
}
