import ComposableArchitecture
import CoreModels
import Foundation

public struct MenuRepository: Sendable {
  public var fetchMenuItems: @Sendable (String?) async throws -> [MenuItem]
  public var fetchMenuDetail: @Sendable (Int) async throws -> MenuItem
  public var createMenu: @Sendable (MenuCreateRequest) async throws -> Void
  public var updateMenuName: @Sendable (Int, MenuNameUpdateRequest) async throws -> Void
  public var updateMenuPrice: @Sendable (Int, MenuPriceUpdateRequest) async throws -> Void
  public var updateMenuCategory: @Sendable (Int, MenuCategoryUpdateRequest) async throws -> Void
  public var updateWorkTime: @Sendable (Int, MenuWorktimeUpdateRequest) async throws -> Void
  public var deleteMenu: @Sendable (Int) async throws -> Void
  public var searchMenus: @Sendable (String) async throws -> [SearchMenusResponse]
  public var checkDupNames: @Sendable (CheckDupRequest) async throws -> CheckDupResponse
  public var fetchTemplate: @Sendable (Int) async throws -> TemplateBasicResponse
  public var fetchTemplateIngredients: @Sendable (Int) async throws -> [RecipeTemplateResponse]
  
  public init(
    fetchMenuItems: @escaping @Sendable (String?) async throws -> [MenuItem],
    fetchMenuDetail: @escaping @Sendable (Int) async throws -> MenuItem,
    createMenu: @escaping @Sendable (MenuCreateRequest) async throws -> Void,
    updateMenuName: @escaping @Sendable (Int, MenuNameUpdateRequest) async throws -> Void,
    updateMenuPrice: @escaping @Sendable (Int, MenuPriceUpdateRequest) async throws -> Void,
    updateMenuCategory: @escaping @Sendable (Int, MenuCategoryUpdateRequest) async throws -> Void,
    updateWorkTime: @escaping @Sendable (Int, MenuWorktimeUpdateRequest) async throws -> Void,
    deleteMenu: @escaping @Sendable (Int) async throws -> Void,
    searchMenus: @escaping @Sendable (String) async throws -> [SearchMenusResponse],
    checkDupNames: @escaping @Sendable (CheckDupRequest) async throws -> CheckDupResponse,
    fetchTemplate: @escaping @Sendable (Int) async throws -> TemplateBasicResponse,
    fetchTemplateIngredients: @escaping @Sendable (Int) async throws -> [RecipeTemplateResponse]
  ) {
    self.fetchMenuItems = fetchMenuItems
    self.fetchMenuDetail = fetchMenuDetail
    self.createMenu = createMenu
    self.updateMenuName = updateMenuName
    self.updateMenuPrice = updateMenuPrice
    self.updateMenuCategory = updateMenuCategory
    self.updateWorkTime = updateWorkTime
    self.deleteMenu = deleteMenu
    self.searchMenus = searchMenus
    self.checkDupNames = checkDupNames
    self.fetchTemplate = fetchTemplate
    self.fetchTemplateIngredients = fetchTemplateIngredients
  }
}

extension MenuRepository: DependencyKey {
  public static let liveValue: MenuRepository = {
    let apiClient = APIClient()
    
    return MenuRepository(
      fetchMenuItems: { category in
        var queryItems: [URLQueryItem]? = nil
        if let category = category {
          queryItems = [URLQueryItem(name: "category", value: category)]
        }
        let response: BaseResponse<[MenuResponse]> = try await apiClient.request(
          path: "/api/v1/catalog/menus",
          method: .get,
          queryItems: queryItems
        )
        guard let data = response.data else { throw APIError.decodingError("Missing data") }
        return data.map { $0.toMenuItem() }
      },
      fetchMenuDetail: { id in
        let response: BaseResponse<MenuDetailResponse> = try await apiClient.request(
          path: "/api/v1/catalog/menus/\(id)",
          method: .get
        )
        guard let data = response.data else { throw APIError.decodingError("Missing data") }
        return data.toMenuItem()
      },
      createMenu: { request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus",
          method: .post,
          body: request
        )
      },
      updateMenuName: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(id)",
          method: .patch,
          body: request
        )
      },
      updateMenuPrice: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(id)/price",
          method: .patch,
          body: request
        )
      },
      updateMenuCategory: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(id)/category",
          method: .patch,
          body: request
        )
      },
      updateWorkTime: { id, request in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(id)/worktime",
          method: .patch,
          body: request
        )
      },
      deleteMenu: { id in
        try await apiClient.requestVoid(
          path: "/api/v1/catalog/menus/\(id)",
          method: .delete
        )
      },
      searchMenus: { keyword in
        let response: BaseResponse<[SearchMenusResponse]> = try await apiClient.request(
          path: "/api/v1/catalog/menus/search",
          method: .get,
          queryItems: [URLQueryItem(name: "keyword", value: keyword)]
        )
        guard let data = response.data else { return [] }
        return data
      },
      checkDupNames: { request in
        let response: BaseResponse<CheckDupResponse> = try await apiClient.request(
          path: "/api/v1/catalog/menus/check-dup",
          method: .post,
          body: request
        )
        guard let data = response.data else { throw APIError.decodingError("Missing data") }
        return data
      },
      fetchTemplate: { templateId in
        let response: BaseResponse<TemplateBasicResponse> = try await apiClient.request(
          path: "/api/v1/catalog/menus/templates/\(templateId)",
          method: .get
        )
        guard let data = response.data else { throw APIError.decodingError("Missing data") }
        return data
      },
      fetchTemplateIngredients: { templateId in
        let response: BaseResponse<[RecipeTemplateResponse]> = try await apiClient.request(
          path: "/api/v1/catalog/menus/templates/\(templateId)/ingredients",
          method: .get
        )
        guard let data = response.data else { return [] }
        return data
      }
    )
  }()
  
  public static let previewValue = MenuRepository(
    fetchMenuItems: { _ in
      try await Task.sleep(for: .milliseconds(100))
      return MockMenuData.items
    },
    fetchMenuDetail: { id in
      guard let item = MockMenuData.items.first else {
        throw APIError.unknown
      }
      return item
    },
    createMenu: { _ in },
    updateMenuName: { _, _ in },
    updateMenuPrice: { _, _ in },
    updateMenuCategory: { _, _ in },
    updateWorkTime: { _, _ in },
    deleteMenu: { _ in },
    searchMenus: { _ in [] },
    checkDupNames: { _ in CheckDupResponse(menuNameDuplicate: false, dupIngredientNames: nil) },
    fetchTemplate: { _ in throw APIError.unknown },
    fetchTemplateIngredients: { _ in [] }
  )
  
  public static let testValue = MenuRepository(
    fetchMenuItems: { _ in [] },
    fetchMenuDetail: { _ in throw APIError.unknown },
    createMenu: { _ in },
    updateMenuName: { _, _ in },
    updateMenuPrice: { _, _ in },
    updateMenuCategory: { _, _ in },
    updateWorkTime: { _, _ in },
    deleteMenu: { _ in },
    searchMenus: { _ in [] },
    checkDupNames: { _ in CheckDupResponse(menuNameDuplicate: false, dupIngredientNames: nil) },
    fetchTemplate: { _ in throw APIError.unknown },
    fetchTemplateIngredients: { _ in [] }
  )
}

public extension DependencyValues {
  var menuRepository: MenuRepository {
    get { self[MenuRepository.self] }
    set { self[MenuRepository.self] = newValue }
  }
}
