import ComposableArchitecture
import CoreModels
import DataLayer
import Foundation

@Reducer
public struct IngredientDetailFeature {
  @Dependency(\.ingredientRepository) var ingredientRepository
  
  public struct State: Equatable {
    var item: InventoryIngredientItem
    var priceHistory: [PriceHistoryResponse] = []
    var priceText: String
    var usageText: String
    var unit: IngredientUnit
    var supplierName: String = ""
    var isEditPresented = false
    var isSupplierPresented = false
    var showDeleteAlert = false
    var isDeleted = false
    var showToast = false
    @PresentationState var alert: AlertState<Action.Alert>?

    public init(item: InventoryIngredientItem) {
      self.item = item
      self.priceHistory = []
      let formattedPrice = IngredientDetailFeature.formattedPriceText(from: item.price)
      let parsed = IngredientDetailFeature.parseAmount(item.amount)
      priceText = formattedPrice
      usageText = parsed.value
      unit = parsed.unit
      if let supplier = item.supplier {
        self.supplierName = supplier
      }
    }
  }

  public enum Action: Equatable {
    case onAppear
    case detailResponse(TaskResult<InventoryIngredientItem>)
    case categoryResponse(TaskResult<String?>)
    case detailFallbackResponse(TaskResult<InventoryIngredientItem?>)
    case priceHistoryResponse(TaskResult<[PriceHistoryResponse]>)
    case ingredientUpdateResponse(TaskResult<Void>)
    case editPresented(Bool)
    case supplierPresented(Bool)
    case editCompleted(price: String, usage: String, unit: IngredientUnit, category: String)
    case supplierCompleted(String)
    case backTapped
    case favoriteTapped
    case favoriteResponse(TaskResult<Void>)
    case deleteTapped
    case deleteAlertConfirmed
    case deleteAlertCancelled
    case deleteResponse(TaskResult<Void>)
    case toastDismissed
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {}
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case (.onAppear, .onAppear): return true
      case let (.detailResponse(.success(l)), .detailResponse(.success(r))): return l == r
      case (.detailResponse(.failure), .detailResponse(.failure)): return true
      case let (.categoryResponse(.success(l)), .categoryResponse(.success(r))): return l == r
      case (.categoryResponse(.failure), .categoryResponse(.failure)): return true
      case let (.detailFallbackResponse(.success(l)), .detailFallbackResponse(.success(r))): return l == r
      case (.detailFallbackResponse(.failure), .detailFallbackResponse(.failure)): return true
      case let (.priceHistoryResponse(.success(l)), .priceHistoryResponse(.success(r))): return l == r
      case (.priceHistoryResponse(.failure), .priceHistoryResponse(.failure)): return true
      case (.ingredientUpdateResponse(.success), .ingredientUpdateResponse(.success)): return true
      case (.ingredientUpdateResponse(.failure), .ingredientUpdateResponse(.failure)): return true
      case let (.editPresented(l), .editPresented(r)): return l == r
      case let (.supplierPresented(l), .supplierPresented(r)): return l == r
      case let (.editCompleted(p1, u1, un1, c1), .editCompleted(p2, u2, un2, c2)):
        return p1 == p2 && u1 == u2 && un1 == un2 && c1 == c2
      case let (.supplierCompleted(l), .supplierCompleted(r)): return l == r
      case (.backTapped, .backTapped): return true
      case (.favoriteTapped, .favoriteTapped): return true
      case (.favoriteResponse(.success), .favoriteResponse(.success)): return true
      case (.favoriteResponse(.failure), .favoriteResponse(.failure)): return true
      case (.deleteTapped, .deleteTapped): return true
      case (.deleteAlertConfirmed, .deleteAlertConfirmed): return true
      case (.deleteAlertCancelled, .deleteAlertCancelled): return true
      case (.deleteResponse(.success), .deleteResponse(.success)): return true
      case (.deleteResponse(.failure), .deleteResponse(.failure)): return true
      case (.toastDismissed, .toastDismissed): return true
      case (.alert, .alert): return true
      default: return false
      }
    }
  }

  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        print(
          "👀 [IngredientDetail] onAppear name=\(state.item.name) apiId=\(String(describing: state.item.apiId)) category=\(state.item.category) amount=\(state.item.amount) price=\(state.item.price)"
        )
        guard let apiId = state.item.apiId else {
          print("❌ [IngredientDetail] apiId is nil - cannot fetch detail")
          return .none
        }
        let currentCategory = state.item.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldFetchCategoryFromList = currentCategory.isEmpty || currentCategory.uppercased() == "ETC"

        let detailEffect: Effect<Action> = .run { send in
          await send(.detailResponse(TaskResult {
            do {
              print("📡 [IngredientDetail] fetch detail start id=\(apiId)")
              let detail = try await ingredientRepository.fetchIngredientDetail(apiId)
              print("✅ [IngredientDetail] fetch detail success id=\(apiId)")
              return detail
            } catch {
              print("❌ [IngredientDetail] fetch detail failed id=\(apiId) error=\(Self.errorDebugString(error))")
              throw error
            }
          }))
        }

        let priceHistoryEffect: Effect<Action> = .run { send in
          await send(.priceHistoryResponse(TaskResult {
            do {
              print("📡 [IngredientDetail] fetch price history start id=\(apiId)")
              let history = try await ingredientRepository.fetchPriceHistory(apiId)
              print("✅ [IngredientDetail] fetch price history success id=\(apiId) count=\(history.count)")
              return history
            } catch {
              print("❌ [IngredientDetail] fetch price history failed id=\(apiId) error=\(Self.errorDebugString(error))")
              throw error
            }
          }))
        }

        guard shouldFetchCategoryFromList else {
          return .merge(detailEffect, priceHistoryEffect)
        }

        let categoryEffect: Effect<Action> = .run { send in
          await send(.categoryResponse(TaskResult {
            do {
              let ingredients = try await ingredientRepository.fetchIngredients(nil)
              let category = ingredients
                .first(where: { $0.apiId == apiId })?
                .category
                .trimmingCharacters(in: .whitespacesAndNewlines)
              return category
            } catch {
              throw error
            }
          }))
        }

        return .merge(detailEffect, priceHistoryEffect, categoryEffect)
        
      case let .detailResponse(.success(item)):
        print("✅ Detail Loaded: \(item.name), menus: \(item.usedMenus)")

        let currentCategory = state.item.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let serverCategory = item.category.trimmingCharacters(in: .whitespacesAndNewlines)

        let resolvedCategory: String
        if !serverCategory.isEmpty, serverCategory.uppercased() != "ETC" {
          resolvedCategory = serverCategory
        } else if !currentCategory.isEmpty, currentCategory.uppercased() != "ETC" {
          resolvedCategory = currentCategory
        } else {
          resolvedCategory = ""
        }
        
        state.item = InventoryIngredientItem(
            id: item.id,
            apiId: item.apiId,
            name: item.name,
            amount: item.amount,
            price: item.price,
            category: resolvedCategory,
            supplier: item.supplier,
            usedMenus: item.usedMenus,
            isFavorite: item.isFavorite
        )
        
        state.priceText = IngredientDetailFeature.formattedPriceText(from: item.price)
        let parsed = IngredientDetailFeature.parseAmount(item.amount)
        state.usageText = parsed.value
        state.unit = parsed.unit
        if let supplier = item.supplier {
          state.supplierName = supplier
        }
        return .none

      case let .categoryResponse(.success(category)):
        guard let category else { return .none }
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .none }

        state.item = InventoryIngredientItem(
          id: state.item.id,
          apiId: state.item.apiId,
          name: state.item.name,
          amount: state.item.amount,
          price: state.item.price,
          category: trimmed,
          supplier: state.item.supplier,
          usedMenus: state.item.usedMenus,
          isFavorite: state.item.isFavorite
        )
        return .none

      case let .categoryResponse(.failure(error)):
        print("❌ [IngredientDetail] categoryResponse failure: \(Self.errorDebugString(error))")
        return .none
        
      case let .detailResponse(.failure(error)):
        if Self.isMissingPriceHistoryError(error), let apiId = state.item.apiId {
          return .run { send in
            await send(.detailFallbackResponse(TaskResult {
              let ingredients = try await ingredientRepository.fetchIngredients(nil)
              return ingredients.first(where: { $0.apiId == apiId })
            }))
          }
        }

        print("❌ [IngredientDetail] detailResponse failure: \(Self.errorDebugString(error))")
        state.alert = AlertState { TextState("재료 상세 정보 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none

      case let .detailFallbackResponse(.success(fallbackItem)):
        guard let fallbackItem else {
          state.alert = AlertState { TextState("재료 상세 정보 로드 실패") } message: { TextState("재료 정보를 찾지 못했어요") }
          return .none
        }

        let existingCategory = state.item.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackCategory = fallbackItem.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedCategory: String
        if !fallbackCategory.isEmpty, fallbackCategory.uppercased() != "ETC" {
          resolvedCategory = fallbackCategory
        } else if !existingCategory.isEmpty, existingCategory.uppercased() != "ETC" {
          resolvedCategory = existingCategory
        } else {
          resolvedCategory = ""
        }

        state.item = InventoryIngredientItem(
          id: fallbackItem.id,
          apiId: fallbackItem.apiId,
          name: fallbackItem.name,
          amount: fallbackItem.amount,
          price: fallbackItem.price,
          category: resolvedCategory,
          supplier: state.item.supplier,
          usedMenus: state.item.usedMenus,
          isFavorite: fallbackItem.isFavorite
        )

        state.priceText = IngredientDetailFeature.formattedPriceText(from: fallbackItem.price)
        let parsed = IngredientDetailFeature.parseAmount(fallbackItem.amount)
        state.usageText = parsed.value
        state.unit = parsed.unit
        return .none

      case let .detailFallbackResponse(.failure(error)):
        print("❌ [IngredientDetail] detailFallbackResponse failure: \(Self.errorDebugString(error))")
        state.alert = AlertState { TextState("재료 상세 정보 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .priceHistoryResponse(.success(history)):
        print("✅ History Loaded: \(history.count) items")
        state.priceHistory = history
        return .none
        
      case let .priceHistoryResponse(.failure(error)):
        if Self.isNotFoundError(error) {
          state.priceHistory = []
          return .none
        }

        print("❌ [IngredientDetail] priceHistoryResponse failure: \(Self.errorDebugString(error))")
        state.alert = AlertState { TextState("가격 변동 이력 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .editPresented(isPresented):
        state.isEditPresented = isPresented
        return .none
        
      case let .supplierPresented(isPresented):
        state.isSupplierPresented = isPresented
        return .none
        
      case let .editCompleted(price, usage, unit, category):
        state.isEditPresented = false
        
        guard let apiId = state.item.apiId else { return .none }
        let numericPrice = price.replacingOccurrences(of: ",", with: "")
        guard let priceValue = Double(numericPrice),
              let amountValue = Double(usage) else { return .none }
              
        let request = IngredientUpdateRequest(
          category: category,
          price: priceValue,
          amount: amountValue,
          unitCode: unit.serverCode
        )
        return .run { send in
          await send(.ingredientUpdateResponse(TaskResult {
            try await ingredientRepository.updateIngredient(apiId, request)
          }))
        }

      case .ingredientUpdateResponse(.success):
        guard let apiId = state.item.apiId else { return .none }
        state.showToast = true
        return .merge(
          .run { send in
            await send(.detailResponse(TaskResult {
              try await ingredientRepository.fetchIngredientDetail(apiId)
            }))
          },
          .run { send in
            await send(.priceHistoryResponse(TaskResult {
              try await ingredientRepository.fetchPriceHistory(apiId)
            }))
          }
        )

      case let .ingredientUpdateResponse(.failure(error)):
        state.alert = AlertState { TextState("재료 수정 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .supplierCompleted(name):
        state.supplierName = name
        state.isSupplierPresented = false
        state.showToast = true
        
        guard let apiId = state.item.apiId else { return .none }
        let request = SupplierUpdateRequest(supplier: name)
        return .run { send in
          try await ingredientRepository.updateSupplier(apiId, request)
        }
        
      case .backTapped:
        return .none
        
      case .favoriteTapped:
        guard let apiId = state.item.apiId else { return .none }
        let newFavorite = !state.item.isFavorite
        return .run { send in
          await send(.favoriteResponse(TaskResult {
            try await ingredientRepository.updateFavorite(apiId, newFavorite)
          }))
        }
        
      case .favoriteResponse(.success):
        state.item.isFavorite.toggle()
        return .none
        
      case let .favoriteResponse(.failure(error)):
        state.alert = AlertState { TextState("즐겨찾기 변경 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case .deleteTapped:
        state.showDeleteAlert = true
        return .none
        
      case .deleteAlertConfirmed:
        state.showDeleteAlert = false
        guard let apiId = state.item.apiId else { return .none }
        return .run { send in
          await send(.deleteResponse(TaskResult {
            try await ingredientRepository.deleteIngredient(apiId)
          }))
        }
        
      case .deleteAlertCancelled:
        state.showDeleteAlert = false
        return .none
        
      case .deleteResponse(.success):
        state.isDeleted = true
        return .none
        
      case let .deleteResponse(.failure(error)):
        state.alert = AlertState { TextState("삭제 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case .toastDismissed:
        state.showToast = false
        return .none

      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
  }
}

private extension IngredientDetailFeature {
  static func errorDebugString(_ error: Error) -> String {
    if let apiError = error as? APIError {
      switch apiError {
      case .invalidURL:
        return "APIError.invalidURL"
      case let .networkError(message):
        return "APIError.networkError(message: \(message))"
      case let .decodingError(message):
        return "APIError.decodingError(message: \(message))"
      case let .serverError(code, message):
        return "APIError.serverError(code: \(code), message: \(message))"
      case .unknown:
        return "APIError.unknown"
      }
    }

    let nsError = error as NSError
    return "\(type(of: error)): \(error.localizedDescription) domain=\(nsError.domain) code=\(nsError.code) userInfo=\(nsError.userInfo)"
  }

  static func formattedPriceText(from value: String) -> String {
    let normalized = value
      .replacingOccurrences(of: ",", with: "")
      .replacingOccurrences(of: "원", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let number = Double(normalized) else { return "" }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: number)) ?? String(format: "%.2f", number)
  }

  static func parseAmount(_ value: String) -> (value: String, unit: IngredientUnit) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    let numeric = trimmed
      .filter { $0.isNumber || $0 == "." || $0 == "," }
      .replacingOccurrences(of: ",", with: "")
    let unitText = String(trimmed.filter { !$0.isNumber && $0 != "." && $0 != "," })
    let unit = IngredientUnit.from(unitText)
    return (numeric.isEmpty ? value : numeric, unit)
  }

  static func isNotFoundError(_ error: Error) -> Bool {
    guard let apiError = error as? APIError else {
      return false
    }

    guard case let .serverError(code, _) = apiError else {
      return false
    }

    return code == 404
  }

  static func isMissingPriceHistoryError(_ error: Error) -> Bool {
    guard let apiError = error as? APIError else {
      return false
    }

    guard case let .serverError(code, message) = apiError else {
      return false
    }

    return code == 404 && message.contains("변경 이력이 없어요")
  }
}
