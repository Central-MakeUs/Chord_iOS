import ComposableArchitecture
import CoreModels
import Foundation

public struct IngredientRepository: Sendable {
  public var fetchIngredients: @Sendable ([String]?) async throws -> [InventoryIngredientItem]
  public var fetchIngredientDetail: @Sendable (Int) async throws -> InventoryIngredientItem
  public var searchIngredients: @Sendable (String) async throws -> [SearchMyIngredientsResponse]
  public var createIngredient: @Sendable (IngredientCreateRequest) async throws -> IngredientResponse
  public var updateIngredient: @Sendable (Int, IngredientUpdateRequest) async throws -> Void
  public var deleteIngredient: @Sendable (Int) async throws -> Void
  public var updateSupplier: @Sendable (Int, SupplierUpdateRequest) async throws -> Void
  public var updateFavorite: @Sendable (Int, Bool) async throws -> Void
  public var fetchPriceHistory: @Sendable (Int) async throws -> [PriceHistoryResponse]
  public var checkDupName: @Sendable (String) async throws -> Bool
  
  public init(
    fetchIngredients: @escaping @Sendable ([String]?) async throws -> [InventoryIngredientItem],
    fetchIngredientDetail: @escaping @Sendable (Int) async throws -> InventoryIngredientItem,
    searchIngredients: @escaping @Sendable (String) async throws -> [SearchMyIngredientsResponse],
    createIngredient: @escaping @Sendable (IngredientCreateRequest) async throws -> IngredientResponse,
    updateIngredient: @escaping @Sendable (Int, IngredientUpdateRequest) async throws -> Void,
    deleteIngredient: @escaping @Sendable (Int) async throws -> Void,
    updateSupplier: @escaping @Sendable (Int, SupplierUpdateRequest) async throws -> Void,
    updateFavorite: @escaping @Sendable (Int, Bool) async throws -> Void,
    fetchPriceHistory: @escaping @Sendable (Int) async throws -> [PriceHistoryResponse],
    checkDupName: @escaping @Sendable (String) async throws -> Bool
  ) {
    self.fetchIngredients = fetchIngredients
    self.fetchIngredientDetail = fetchIngredientDetail
    self.searchIngredients = searchIngredients
    self.createIngredient = createIngredient
    self.updateIngredient = updateIngredient
    self.deleteIngredient = deleteIngredient
    self.updateSupplier = updateSupplier
    self.updateFavorite = updateFavorite
    self.fetchPriceHistory = fetchPriceHistory
    self.checkDupName = checkDupName
  }
}

extension IngredientRepository: DependencyKey {
  public static let liveValue: IngredientRepository = {
    let apiClient = APIClient()
    
    return IngredientRepository(
      fetchIngredients: { categories in
        var queryItems: [URLQueryItem]? = nil
        if let categories = categories {
          queryItems = categories.map { URLQueryItem(name: "category", value: $0) }
        }
        let responses: [IngredientResponse] = try await apiClient.request(
          path: "/api/v1/catalog/ingredients",
          method: .get,
          queryItems: queryItems
        )
        return responses.map { $0.toInventoryIngredientItem() }
      },
      fetchIngredientDetail: { id in
        let response: IngredientDetailResponse = try await apiClient.request(
          path: "/api/v1/catalog/ingredients/\(id)",
          method: .get
        )
        return response.toInventoryIngredientItem()
      },
      searchIngredients: { query in
        let responses: [SearchMyIngredientsResponse] = try await apiClient.request(
          path: "/api/v1/catalog/ingredients/search/my",
          method: .get,
          queryItems: [URLQueryItem(name: "keyword", value: query)]
        )
        return responses
      },
      createIngredient: { request in
        let response: IngredientResponse = try await apiClient.request(
          path: "/api/v1/catalog/ingredients",
          method: .post,
          body: request
        )
        return response
      },
      updateIngredient: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/ingredients/\(id)",
          method: .patch,
          body: request
        )
      },
      deleteIngredient: { id in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/ingredients/\(id)",
          method: .delete
        )
      },
      updateSupplier: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/ingredients/\(id)/supplier",
          method: .patch,
          body: request
        )
      },
      updateFavorite: { id, favorite in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/ingredients/\(id)/favorite",
          method: .patch,
          queryItems: [URLQueryItem(name: "favorite", value: String(favorite))]
        )
      },
      fetchPriceHistory: { id in
        let responses: [PriceHistoryResponse] = try await apiClient.request(
          path: "/api/v1/catalog/ingredients/\(id)/price-history",
          method: .get
        )
        return responses
      },
      checkDupName: { name in
        do {
          try await apiClient.requestVoid(
            path: "/api/v1/catalog/ingredients/check-dup",
            method: .get,
            queryItems: [URLQueryItem(name: "name", value: name)]
          )
          return false
        } catch {
          return true
        }
      }
    )
  }()
  
  public static let previewValue = IngredientRepository(
    fetchIngredients: { _ in
      try await Task.sleep(for: .milliseconds(100))
      return MockIngredientData.items
    },
    fetchIngredientDetail: { id in
      try await Task.sleep(for: .milliseconds(100))
      return MockIngredientData.items.first(where: { $0.apiId == id }) ?? MockIngredientData.items[0]
    },
    searchIngredients: { query in
      try await Task.sleep(for: .milliseconds(100))
      let lowercasedQuery = query.lowercased()
      return MockIngredientData.items
        .filter { $0.name.lowercased().contains(lowercasedQuery) }
        .map { SearchMyIngredientsResponse(ingredientId: 0, ingredientName: $0.name) }
    },
    createIngredient: { _ in throw APIError.unknown },
    updateIngredient: { _, _ in },
    deleteIngredient: { _ in },
    updateSupplier: { _, _ in },
    updateFavorite: { _, _ in },
    fetchPriceHistory: { _ in [] },
    checkDupName: { _ in false }
  )
  
  public static let testValue = IngredientRepository(
    fetchIngredients: { _ in [] },
    fetchIngredientDetail: { _ in throw APIError.unknown },
    searchIngredients: { _ in [] },
    createIngredient: { _ in throw APIError.unknown },
    updateIngredient: { _, _ in },
    deleteIngredient: { _ in },
    updateSupplier: { _, _ in },
    updateFavorite: { _, _ in },
    fetchPriceHistory: { _ in [] },
    checkDupName: { _ in false }
  )
}

public extension DependencyValues {
  var ingredientRepository: IngredientRepository {
    get { self[IngredientRepository.self] }
    set { self[IngredientRepository.self] = newValue }
  }
}
