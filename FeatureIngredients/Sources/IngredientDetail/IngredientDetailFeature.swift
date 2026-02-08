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
      let priceDigits = item.price.filter { $0.isNumber }
      let formattedPrice = IngredientDetailFeature.formattedNumber(from: priceDigits)
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
    case priceHistoryResponse(TaskResult<[PriceHistoryResponse]>)
    case editPresented(Bool)
    case supplierPresented(Bool)
    case editCompleted(price: String, usage: String, unit: IngredientUnit)
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
      case let (.priceHistoryResponse(.success(l)), .priceHistoryResponse(.success(r))): return l == r
      case (.priceHistoryResponse(.failure), .priceHistoryResponse(.failure)): return true
      case let (.editPresented(l), .editPresented(r)): return l == r
      case let (.supplierPresented(l), .supplierPresented(r)): return l == r
      case let (.editCompleted(p1, u1, un1), .editCompleted(p2, u2, un2)): return p1 == p2 && u1 == u2 && un1 == un2
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
        print("👀 IngredientDetail OnAppear. apiId: \(String(describing: state.item.apiId))")
        guard let apiId = state.item.apiId else { 
          print("❌ apiId is nil")
          return .none 
        }
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
        
      case let .detailResponse(.success(item)):
        print("✅ Detail Loaded: \(item.name), menus: \(item.usedMenus)")
        
        // Use the category explicitly from the existing state (passed from parent view)
        // because the detail API response might be missing it or defaulting to "ETC".
        let validCategory = state.item.category
        
        state.item = InventoryIngredientItem(
            id: item.id,
            apiId: item.apiId,
            name: item.name,
            amount: item.amount,
            price: item.price,
            category: validCategory, // Force use of existing valid category
            supplier: item.supplier,
            usedMenus: item.usedMenus,
            isFavorite: item.isFavorite
        )
        
        let priceDigits = item.price.filter { $0.isNumber }
        state.priceText = IngredientDetailFeature.formattedNumber(from: priceDigits)
        let parsed = IngredientDetailFeature.parseAmount(item.amount)
        state.usageText = parsed.value
        state.unit = parsed.unit
        if let supplier = item.supplier {
          state.supplierName = supplier
        }
        return .none
        
      case let .detailResponse(.failure(error)):
        state.alert = AlertState { TextState("재료 상세 정보 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .priceHistoryResponse(.success(history)):
        print("✅ History Loaded: \(history.count) items")
        state.priceHistory = history
        return .none
        
      case let .priceHistoryResponse(.failure(error)):
        state.alert = AlertState { TextState("가격 변동 이력 로드 실패") } message: { TextState(error.localizedDescription) }
        return .none
        
      case let .editPresented(isPresented):
        state.isEditPresented = isPresented
        return .none
        
      case let .supplierPresented(isPresented):
        state.isSupplierPresented = isPresented
        return .none
        
      case let .editCompleted(price, usage, unit):
        state.priceText = price
        state.usageText = usage
        state.unit = unit
        state.isEditPresented = false
        state.showToast = true
        
        guard let apiId = state.item.apiId else { return .none }
        let numericPrice = price.replacingOccurrences(of: ",", with: "")
        guard let priceValue = Double(numericPrice),
              let amountValue = Double(usage) else { return .none }
              
        let request = IngredientUpdateRequest(
          category: state.item.category,
          price: priceValue,
          amount: amountValue,
          unitCode: unit.serverCode
        )
        return .run { send in
          try await ingredientRepository.updateIngredient(apiId, request)
        }
        
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
  static func formattedNumber(from value: String) -> String {
    guard let number = Int64(value) else { return "" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? value
  }

  static func parseAmount(_ value: String) -> (value: String, unit: IngredientUnit) {
    let digits = value.filter { $0.isNumber }
    let unitText = value.filter { !$0.isNumber }
    let unit = IngredientUnit.from(unitText)
    return (digits.isEmpty ? value : digits, unit)
  }
}
