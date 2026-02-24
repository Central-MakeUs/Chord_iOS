import Foundation
import CoreModels
import Dependencies

public struct AuthRepository: Sendable {
  public var login: @Sendable (String, String) async throws -> Bool
  public var signUp: @Sendable (String, String) async throws -> Void
  public var refresh: @Sendable () async throws -> Void
  public var logout: @Sendable () async throws -> Void
  
  public init(
    login: @escaping @Sendable (String, String) async throws -> Bool,
    signUp: @escaping @Sendable (String, String) async throws -> Void,
    refresh: @escaping @Sendable () async throws -> Void,
    logout: @escaping @Sendable () async throws -> Void
  ) {
    self.login = login
    self.signUp = signUp
    self.refresh = refresh
    self.logout = logout
  }
}

extension AuthRepository: DependencyKey {
  public static let liveValue: AuthRepository = {
    let apiClient = APIClient()
    let tokenStorage = TokenStorage.shared
    let keychainStorage = KeychainStorage.shared
    
    return AuthRepository(
      login: { loginId, password in
        let userDefaults = UserDefaults.standard
        let fcmToken = userDefaults.string(forKey: "fcmToken")?.trimmingCharacters(in: .whitespacesAndNewlines)
        let deviceId = userDefaults.string(forKey: "deviceId")?.trimmingCharacters(in: .whitespacesAndNewlines)

        let request = LoginRequest(
          loginId: loginId,
          password: password,
          fcmToken: fcmToken?.isEmpty == true ? nil : fcmToken,
          deviceType: "IOS",
          deviceId: deviceId?.isEmpty == true ? nil : deviceId
        )
        let response: BaseResponse<LoginResponse> = try await apiClient.request(
          path: "/api/v1/auth/login",
          method: .post,
          body: request
        )
        
        guard let data = response.data else {
          throw APIError.decodingError("Missing token data")
        }
        
        // Only save tokens if onboarding is completed
        if data.onboardingCompleted {
            await tokenStorage.setAccessToken(data.accessToken)
            try await keychainStorage.saveRefreshToken(data.refreshToken)
            print("✅ Login successful. Tokens stored. OnboardingCompleted: true")
        } else {
            await tokenStorage.setAccessToken(data.accessToken)
            await tokenStorage.setTempRefreshToken(data.refreshToken)
            print("⚠️ Login successful but Onboarding NOT completed. RefreshToken stored in memory only.")
        }
        
        return data.onboardingCompleted
      },
      signUp: { loginId, password in
        let request = SignUpRequest(loginId: loginId, password: password)
        let _: BaseResponse<EmptyResponse> = try await apiClient.request(
          path: "/api/v1/auth/sign-up",
          method: .post,
          body: request
        )
        print("✅ SignUp successful.")
      },
      refresh: {
        print("🔄 [AutoLogin] Starting token refresh...")
        
        let refreshToken = await keychainStorage.getRefreshToken()
        if let token = refreshToken {
          print("🔑 [AutoLogin] RefreshToken found in Keychain (length: \(token.count), prefix: \(String(token.prefix(10)))...)")
        } else {
          print("❌ [AutoLogin] No refreshToken in Keychain!")
          throw APIError.networkError("No refresh token in Keychain")
        }
        
        print("📡 [AutoLogin] Calling /api/v1/auth/refresh...")
        let request = TokenRefreshRequest(refreshToken: refreshToken!)
        
        do {
          let response: BaseResponse<TokenRefreshResponse> = try await apiClient.request(
            path: "/api/v1/auth/refresh",
            method: .post,
            body: request
          )
          
          guard let data = response.data else {
            print("❌ [AutoLogin] Server response missing token data")
            throw APIError.decodingError("Missing token data")
          }
          
          await tokenStorage.setAccessToken(data.accessToken)
          print("✅ [AutoLogin] Token refreshed successfully! New accessToken stored.")
        } catch {
          print("❌ [AutoLogin] Refresh API failed: \(error)")
          throw error
        }
      },
      logout: {
        await tokenStorage.clear()
        try await keychainStorage.deleteRefreshToken()
        print("✅ Logout successful. All tokens cleared.")
      }
    )
  }()
  
  public static let previewValue = AuthRepository(
    login: { _, _ in
      print("✅ [Preview] Login successful.")
      return true
    },
    signUp: { _, _ in
      print("✅ [Preview] SignUp successful.")
    },
    refresh: {
      print("✅ [Preview] Token refreshed.")
    },
    logout: {
      print("✅ [Preview] Logout successful.")
    }
  )
  
  public static let testValue = AuthRepository(
    login: { _, _ in true },
    signUp: { _, _ in },
    refresh: { },
    logout: { }
  )
}

public extension DependencyValues {
  var authRepository: AuthRepository {
    get { self[AuthRepository.self] }
    set { self[AuthRepository.self] = newValue }
  }
}
