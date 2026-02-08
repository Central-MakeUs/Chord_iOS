import Foundation

public struct LoginRequest: Codable, Equatable {
  public let loginId: String
  public let password: String
  
  public init(loginId: String, password: String) {
    self.loginId = loginId
    self.password = password
  }
}

public struct LoginResponse: Codable, Equatable {
  public let accessToken: String
  public let refreshToken: String
  public let onboardingCompleted: Bool
  
  public init(accessToken: String, refreshToken: String, onboardingCompleted: Bool) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.onboardingCompleted = onboardingCompleted
  }
}

public struct SignUpRequest: Codable, Equatable {
  public let loginId: String
  public let password: String
  
  public init(loginId: String, password: String) {
    self.loginId = loginId
    self.password = password
  }
}

public struct TokenRefreshRequest: Codable, Equatable {
  public let refreshToken: String
  
  public init(refreshToken: String) {
    self.refreshToken = refreshToken
  }
}

public struct TokenRefreshResponse: Codable, Equatable {
  public let accessToken: String
  
  public init(accessToken: String) {
    self.accessToken = accessToken
  }
}
