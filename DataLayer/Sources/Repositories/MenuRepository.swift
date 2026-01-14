import ComposableArchitecture
import CoreModels
import Foundation

public struct MenuRepository: Sendable {
  public var fetchMenuItems: @Sendable () async throws -> [MenuItem]
  public var fetchMenuItemByID: @Sendable (UUID) async throws -> MenuItem?
  
  public init(
    fetchMenuItems: @escaping @Sendable () async throws -> [MenuItem],
    fetchMenuItemByID: @escaping @Sendable (UUID) async throws -> MenuItem?
  ) {
    self.fetchMenuItems = fetchMenuItems
    self.fetchMenuItemByID = fetchMenuItemByID
  }
}

extension MenuRepository: DependencyKey {
  public static let liveValue = MenuRepository(
    fetchMenuItems: {
      try await Task.sleep(for: .milliseconds(300))
      return []
    },
    fetchMenuItemByID: { _ in
      try await Task.sleep(for: .milliseconds(200))
      return nil
    }
  )
  
  public static let previewValue = MenuRepository(
    fetchMenuItems: {
      try await Task.sleep(for: .milliseconds(100))
      return MockMenuData.items
    },
    fetchMenuItemByID: { id in
      try await Task.sleep(for: .milliseconds(50))
      return MockMenuData.items.first { $0.id == id }
    }
  )
  
  public static let testValue = MenuRepository(
    fetchMenuItems: { [] },
    fetchMenuItemByID: { _ in nil }
  )
}

public extension DependencyValues {
  var menuRepository: MenuRepository {
    get { self[MenuRepository.self] }
    set { self[MenuRepository.self] = newValue }
  }
}
