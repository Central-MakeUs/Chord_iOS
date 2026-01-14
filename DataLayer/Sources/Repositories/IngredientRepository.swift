import ComposableArchitecture
import CoreModels
import Foundation

public struct IngredientRepository: Sendable {
  public var fetchIngredients: @Sendable () async throws -> [InventoryIngredientItem]
  public var fetchIngredientByID: @Sendable (UUID) async throws -> InventoryIngredientItem?
  public var searchIngredients: @Sendable (String) async throws -> [InventoryIngredientItem]
  
  public init(
    fetchIngredients: @escaping @Sendable () async throws -> [InventoryIngredientItem],
    fetchIngredientByID: @escaping @Sendable (UUID) async throws -> InventoryIngredientItem?,
    searchIngredients: @escaping @Sendable (String) async throws -> [InventoryIngredientItem]
  ) {
    self.fetchIngredients = fetchIngredients
    self.fetchIngredientByID = fetchIngredientByID
    self.searchIngredients = searchIngredients
  }
}

extension IngredientRepository: DependencyKey {
  public static let liveValue = IngredientRepository(
    fetchIngredients: {
      try await Task.sleep(for: .milliseconds(300))
      return []
    },
    fetchIngredientByID: { _ in
      try await Task.sleep(for: .milliseconds(200))
      return nil
    },
    searchIngredients: { _ in
      try await Task.sleep(for: .milliseconds(300))
      return []
    }
  )
  
  public static let previewValue = IngredientRepository(
    fetchIngredients: {
      try await Task.sleep(for: .milliseconds(100))
      return MockIngredientData.items
    },
    fetchIngredientByID: { id in
      try await Task.sleep(for: .milliseconds(50))
      return MockIngredientData.items.first { $0.id == id }
    },
    searchIngredients: { query in
      try await Task.sleep(for: .milliseconds(100))
      let lowercasedQuery = query.lowercased()
      return MockIngredientData.items.filter { $0.name.lowercased().contains(lowercasedQuery) }
    }
  )
  
  public static let testValue = IngredientRepository(
    fetchIngredients: { [] },
    fetchIngredientByID: { _ in nil },
    searchIngredients: { _ in [] }
  )
}

public extension DependencyValues {
  var ingredientRepository: IngredientRepository {
    get { self[IngredientRepository.self] }
    set { self[IngredientRepository.self] = newValue }
  }
}
