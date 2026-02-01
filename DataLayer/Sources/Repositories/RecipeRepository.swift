import ComposableArchitecture
import CoreModels
import Foundation

public struct RecipeRepository: Sendable {
  public var fetchRecipes: @Sendable (Int) async throws -> RecipeListResponse
  public var createRecipeWithExisting: @Sendable (Int, RecipeCreateRequest) async throws -> Void
  public var createRecipeWithNew: @Sendable (Int, NewRecipeCreateRequest) async throws -> Void
  public var updateRecipe: @Sendable (Int, Int, AmountUpdateRequest) async throws -> Void
  public var deleteRecipes: @Sendable (Int, DeleteRecipesRequest) async throws -> Void
  
  public init(
    fetchRecipes: @escaping @Sendable (Int) async throws -> RecipeListResponse,
    createRecipeWithExisting: @escaping @Sendable (Int, RecipeCreateRequest) async throws -> Void,
    createRecipeWithNew: @escaping @Sendable (Int, NewRecipeCreateRequest) async throws -> Void,
    updateRecipe: @escaping @Sendable (Int, Int, AmountUpdateRequest) async throws -> Void,
    deleteRecipes: @escaping @Sendable (Int, DeleteRecipesRequest) async throws -> Void
  ) {
    self.fetchRecipes = fetchRecipes
    self.createRecipeWithExisting = createRecipeWithExisting
    self.createRecipeWithNew = createRecipeWithNew
    self.updateRecipe = updateRecipe
    self.deleteRecipes = deleteRecipes
  }
}

extension RecipeRepository: DependencyKey {
  public static let liveValue: RecipeRepository = {
    let apiClient = APIClient()
    
    return RecipeRepository(
      fetchRecipes: { menuId in
        let response: RecipeListResponse = try await apiClient.request(
          path: "/api/v1/catalog/menus/\(menuId)/recipes",
          method: .get
        )
        return response
      },
      createRecipeWithExisting: { menuId, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(menuId)/recipes/existing",
          method: .post,
          body: request
        )
      },
      createRecipeWithNew: { menuId, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(menuId)/recipes/new",
          method: .post,
          body: request
        )
      },
      updateRecipe: { menuId, recipeId, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(menuId)/recipes/\(recipeId)",
          method: .patch,
          body: request
        )
      },
      deleteRecipes: { menuId, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(menuId)/recipes",
          method: .delete,
          body: request
        )
      }
    )
  }()
  
  public static let previewValue = RecipeRepository(
    fetchRecipes: { _ in
      RecipeListResponse(recipes: [], totalCost: 0)
    },
    createRecipeWithExisting: { _, _ in },
    createRecipeWithNew: { _, _ in },
    updateRecipe: { _, _, _ in },
    deleteRecipes: { _, _ in }
  )
  
  public static let testValue = RecipeRepository(
    fetchRecipes: { _ in
      RecipeListResponse(recipes: [], totalCost: 0)
    },
    createRecipeWithExisting: { _, _ in },
    createRecipeWithNew: { _, _ in },
    updateRecipe: { _, _, _ in },
    deleteRecipes: { _, _ in }
  )
}

public extension DependencyValues {
  var recipeRepository: RecipeRepository {
    get { self[RecipeRepository.self] }
    set { self[RecipeRepository.self] = newValue }
  }
}
