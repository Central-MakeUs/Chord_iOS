import ComposableArchitecture
import CoreModels
import Foundation

public struct CategoryRepository: Sendable {
  public var fetchMenuCategories: @Sendable () async throws -> [MenuCategoryResponse]
  public var fetchIngredientCategories: @Sendable () async throws -> [IngredientCategoryResponse]
  
  public init(
    fetchMenuCategories: @escaping @Sendable () async throws -> [MenuCategoryResponse],
    fetchIngredientCategories: @escaping @Sendable () async throws -> [IngredientCategoryResponse]
  ) {
    self.fetchMenuCategories = fetchMenuCategories
    self.fetchIngredientCategories = fetchIngredientCategories
  }
}

extension CategoryRepository: DependencyKey {
  public static let liveValue: CategoryRepository = {
    let apiClient = APIClient()
    
    return CategoryRepository(
      fetchMenuCategories: {
        let responses: [MenuCategoryResponse] = try await apiClient.request(
          path: "/api/v1/catalog/menu-categories",
          method: .get
        )
        return responses
      },
      fetchIngredientCategories: {
        let responses: [IngredientCategoryResponse] = try await apiClient.request(
          path: "/api/v1/catalog/ingredient-categories",
          method: .get
        )
        return responses
      }
    )
  }()
  
  public static let previewValue = CategoryRepository(
    fetchMenuCategories: { [] },
    fetchIngredientCategories: { [] }
  )
  
  public static let testValue = CategoryRepository(
    fetchMenuCategories: { [] },
    fetchIngredientCategories: { [] }
  )
}

public extension DependencyValues {
  var categoryRepository: CategoryRepository {
    get { self[CategoryRepository.self] }
    set { self[CategoryRepository.self] = newValue }
  }
}
