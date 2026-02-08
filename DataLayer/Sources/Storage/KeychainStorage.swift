import Foundation
import Security
import Dependencies

public actor KeychainStorage: Sendable {
  public static let shared = KeychainStorage()
  
  private let service = "com.seungwan.CoachCoach"
  private let refreshTokenKey = "refreshToken"
  
  private init() {}
  
  public func saveRefreshToken(_ token: String) throws {
    let data = token.data(using: .utf8)!
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: refreshTokenKey,
      kSecValueData as String: data
    ]
    
    SecItemDelete(query as CFDictionary)
    
    let status = SecItemAdd(query as CFDictionary, nil)
    
    guard status == errSecSuccess else {
      throw KeychainError.saveFailed(status)
    }
  }
  
  public func getRefreshToken() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: refreshTokenKey,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess,
          let data = result as? Data,
          let token = String(data: data, encoding: .utf8) else {
      return nil
    }
    
    return token
  }
  
  public func deleteRefreshToken() throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: refreshTokenKey
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.deleteFailed(status)
    }
  }
}

public enum KeychainError: Error {
  case saveFailed(OSStatus)
  case deleteFailed(OSStatus)
}

public extension DependencyValues {
  var keychainStorage: KeychainStorage {
    get { self[KeychainStorageKey.self] }
    set { self[KeychainStorageKey.self] = newValue }
  }
}

private enum KeychainStorageKey: DependencyKey {
  static let liveValue = KeychainStorage.shared
}
