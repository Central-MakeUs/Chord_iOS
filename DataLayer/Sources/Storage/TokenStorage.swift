import Foundation
import Dependencies

public actor TokenStorage: Sendable {
  public static let shared = TokenStorage()
  
  private var accessToken: String?
  private var tempRefreshToken: String?
  
  public func setAccessToken(_ token: String) {
    self.accessToken = token
  }
  
  public func setTempRefreshToken(_ token: String) {
    self.tempRefreshToken = token
  }
  
  public func getTempRefreshToken() -> String? {
    return self.tempRefreshToken
  }
  
  public func getAccessToken() -> String? {
    return self.accessToken
  }
  
  public func clear() {
    self.accessToken = nil
    self.tempRefreshToken = nil
  }
}

public extension DependencyValues {
  var tokenStorage: TokenStorage {
    get { self[TokenStorageKey.self] }
    set { self[TokenStorageKey.self] = newValue }
  }
}

private enum TokenStorageKey: DependencyKey {
  static let liveValue = TokenStorage.shared
}
