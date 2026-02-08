import Foundation
import CoreModels
import Dependencies

public struct UserRepository: Sendable {
  public var saveOnboarding: @Sendable (String, Int, Double, Bool) async throws -> Void
  
  public init(
    saveOnboarding: @escaping @Sendable (String, Int, Double, Bool) async throws -> Void
  ) {
    self.saveOnboarding = saveOnboarding
  }
}

extension UserRepository: DependencyKey {
  public static let liveValue: UserRepository = {
    let apiClient = APIClient()
    let tokenStorage = TokenStorage.shared
    let keychainStorage = KeychainStorage.shared
    
    return UserRepository(
      saveOnboarding: { name, employees, laborCost, includeWeeklyHolidayPay in
        let request = OnboardingRequest(
          name: name,
          employees: employees,
          laborCost: laborCost,
          includeWeeklyHolidayPay: includeWeeklyHolidayPay
        )
        let _: BaseResponse<EmptyResponse> = try await apiClient.request(
          path: "/api/v1/users/onboarding",
          method: .patch,
          body: request
        )
        print("✅ Onboarding data saved to server")
        
        if let tempRefreshToken = await tokenStorage.getTempRefreshToken() {
            try await keychainStorage.saveRefreshToken(tempRefreshToken)
            print("🔐 Onboarding completed. RefreshToken moved from Memory to Keychain.")
        } else {
            print("⚠️ Warning: No tempRefreshToken found in TokenStorage after onboarding.")
        }
      }
    )
  }()
  
  public static let previewValue = UserRepository(
    saveOnboarding: { _, _, _, _ in
      print("✅ [Preview] Onboarding saved")
    }
  )
  
  public static let testValue = UserRepository(
    saveOnboarding: { _, _, _, _ in }
  )
}

public extension DependencyValues {
  var userRepository: UserRepository {
    get { self[UserRepository.self] }
    set { self[UserRepository.self] = newValue }
  }
}
