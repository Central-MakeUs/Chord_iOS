import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

@Reducer
public struct MenuRegistrationFeature {
  @Dependency(\.menuRepository) var menuRepository

  public enum Step: Equatable {
    case step1
    case step2
  }

  public struct RegistrationIngredient: Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var amount: Double
    public var unitCode: String
    public var price: Double
    public var ingredientId: Int?
    public var isFromTemplate: Bool

    public init(
      id: UUID = UUID(),
      name: String,
      amount: Double,
      unitCode: String,
      price: Double,
      ingredientId: Int? = nil,
      isFromTemplate: Bool = false
    ) {
      self.id = id
      self.name = name
      self.amount = amount
      self.unitCode = unitCode
      self.price = price
      self.ingredientId = ingredientId
      self.isFromTemplate = isFromTemplate
    }

    public var formattedAmount: String {
      let intAmount = Int(amount)
      if Double(intAmount) == amount {
        return "\(intAmount)\(unitCode)"
      }
      return "\(amount)\(unitCode)"
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

  public struct State: Equatable {
    public var currentStep: Step = .step1
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
    public var showTemplateSheet: Bool = false
    public var selectedTemplateName: String = ""

    public var addedIngredients: [RegistrationIngredient] = []
    public var templateIngredients: [RecipeTemplateResponse] = []
    public var ingredientInput: String = ""

    public var showIngredientDetailSheet: Bool = false
    public var selectedIngredientIndex: Int?

    public var isCreating: Bool = false
    public var error: String?

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
    case applyTemplateTapped
    case cancelTemplateTapped
    case dismissSuggestions

    case nextStepTapped
    case previousStepTapped
    case backTapped

    case ingredientInputChanged(String)
    case addIngredientTapped
    case removeIngredient(UUID)
    case ingredientTapped(Int)
    case templateIngredientTapped(Int)
    case showIngredientDetailSheetChanged(Bool)

    case completeTapped
    case createMenuResponse(Result<Void, Error>)

    case delegate(Delegate)

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
      case (.applyTemplateTapped, .applyTemplateTapped): return true
      case (.cancelTemplateTapped, .cancelTemplateTapped): return true
      case (.dismissSuggestions, .dismissSuggestions): return true
      case (.nextStepTapped, .nextStepTapped): return true
      case (.previousStepTapped, .previousStepTapped): return true
      case (.backTapped, .backTapped): return true
      case let (.ingredientInputChanged(l), .ingredientInputChanged(r)): return l == r
      case (.addIngredientTapped, .addIngredientTapped): return true
      case let (.removeIngredient(l), .removeIngredient(r)): return l == r
      case let (.ingredientTapped(l), .ingredientTapped(r)): return l == r
      case let (.templateIngredientTapped(l), .templateIngredientTapped(r)): return l == r
      case let (.showIngredientDetailSheetChanged(l), .showIngredientDetailSheetChanged(r)): return l == r
      case (.completeTapped, .completeTapped): return true
      case (.createMenuResponse(.success), .createMenuResponse(.success)): return true
      case (.createMenuResponse(.failure), .createMenuResponse(.failure)): return true
      case let (.delegate(l), .delegate(r)): return l == r
      default: return false
      }
    }
  }

  public init() {}

  private enum CancelID { case search }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .menuNameChanged(name):
        state.menuName = name
        if name.isEmpty {
          state.showSuggestions = false
          state.searchResults = []
          state.isTemplateApplied = false
          state.templateId = nil
          return .cancel(id: CancelID.search)
        }
        if state.isTemplateApplied { return .none }
        state.showSuggestions = true
        state.isSearching = true
        let keyword = name
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          let result = await Result { try await menuRepository.searchMenus(keyword) }
          await send(.searchMenusResponse(result))
        }
        .cancellable(id: CancelID.search, cancelInFlight: true)

      case let .priceChanged(price):
        state.price = price
        return .none

      case let .categorySelected(category):
        state.selectedCategory = category
        return .none

      case let .workTimeUpdated(minutes, seconds):
        state.workTimeMinutes = minutes
        state.workTimeSeconds = seconds
        return .none

      case .clearMenuNameTapped:
        state.menuName = ""
        state.isTemplateApplied = false
        state.showSuggestions = false
        state.searchResults = []
        state.templateId = nil
        state.price = ""
        state.addedIngredients = []
        state.templateIngredients = []
        return .cancel(id: CancelID.search)

      case let .searchMenusResponse(.success(results)):
        state.searchResults = results
        state.isSearching = false
        return .none

      case .searchMenusResponse(.failure):
        state.searchResults = []
        state.isSearching = false
        return .none

      case let .templateSelected(template):
        state.menuName = template.menuName
        state.selectedTemplateName = template.menuName
        state.templateId = template.templateId
        state.showSuggestions = false
        state.showTemplateSheet = true
        return .none

      case let .showTemplateSheetChanged(isPresented):
        state.showTemplateSheet = isPresented
        return .none

      case .applyTemplateTapped:
        state.showTemplateSheet = false
        state.isTemplateApplied = true
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
        state.templateIngredients = ingredients
        state.addedIngredients = ingredients.map { ingredient in
          RegistrationIngredient(
            name: ingredient.ingredientName,
            amount: ingredient.defaultUsageAmount,
            unitCode: ingredient.unitCode,
            price: ingredient.defaultPrice
          )
        }
        return .none

      case .fetchTemplateIngredientsResponse(.failure):
        state.error = "템플릿 재료를 불러올 수 없습니다"
        return .none

      case .dismissSuggestions:
        state.showSuggestions = false
        return .none

      case .nextStepTapped:
        state.currentStep = .step2
        return .none

      case .previousStepTapped:
        switch state.currentStep {
        case .step1:
          return .send(.delegate(.dismissed))
        case .step2:
          state.currentStep = .step1
          return .none
        }

      case .backTapped:
        return .send(.delegate(.dismissed))

      case let .ingredientInputChanged(input):
        state.ingredientInput = input
        return .none

      case .addIngredientTapped:
        let name = state.ingredientInput.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return .none }
        let newIngredient = RegistrationIngredient(
          name: name,
          amount: 0,
          unitCode: "g",
          price: 0
        )
        state.addedIngredients.append(newIngredient)
        state.ingredientInput = ""
        return .none

      case let .removeIngredient(id):
        state.addedIngredients.removeAll { $0.id == id }
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

      case .completeTapped:
        let numericPrice = state.price.replacingOccurrences(of: ",", with: "")
        guard let sellingPrice = Double(numericPrice) else { return .none }
        let totalSeconds = state.workTimeMinutes * 60 + state.workTimeSeconds

        let recipes: [RecipeCreateRequest] = state.addedIngredients.compactMap { ingredient in
          guard let ingredientId = ingredient.ingredientId else { return nil }
          return RecipeCreateRequest(ingredientId: ingredientId, amount: ingredient.amount)
        }

        let newRecipes: [NewRecipeCreateRequest] = state.addedIngredients.compactMap { ingredient in
          guard ingredient.ingredientId == nil else { return nil }
          return NewRecipeCreateRequest(
            amount: ingredient.amount,
            price: ingredient.price,
            unitCode: ingredient.unitCode,
            ingredientCategoryCode: "ETC",
            ingredientName: ingredient.name
          )
        }

        let request = MenuCreateRequest(
          menuCategoryCode: state.categoryCode,
          menuName: state.menuName,
          sellingPrice: sellingPrice,
          workTime: totalSeconds,
          recipes: recipes.isEmpty ? nil : recipes,
          newRecipes: newRecipes.isEmpty ? nil : newRecipes
        )

        state.isCreating = true
        return .run { send in
          let result = await Result { try await menuRepository.createMenu(request) }
          await send(.createMenuResponse(result))
        }

      case .createMenuResponse(.success):
        state.isCreating = false
        return .send(.delegate(.menuCreated))

      case .createMenuResponse(.failure):
        state.isCreating = false
        state.error = "메뉴 생성에 실패했습니다"
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

private extension MenuRegistrationFeature {
  func categoryNameFromCode(_ code: String) -> String {
    switch code {
    case "BEVERAGE": return "음료"
    case "DESSERT": return "디저트"
    case "FOOD": return "푸드"
    default: return "음료"
    }
  }
}
