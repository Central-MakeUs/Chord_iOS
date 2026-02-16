import Foundation
import CoreModels
import Dependencies

public struct UserRepository: Sendable {
  public var saveOnboarding: @Sendable (String, Int, Double, Bool) async throws -> Void
  public var fetchStore: @Sendable () async throws -> StoreResponse
  public var updateStore: @Sendable (String, Int, Double, Bool?) async throws -> Void
  public var withdraw: @Sendable () async throws -> Void
  
  public init(
    saveOnboarding: @escaping @Sendable (String, Int, Double, Bool) async throws -> Void,
    fetchStore: @escaping @Sendable () async throws -> StoreResponse,
    updateStore: @escaping @Sendable (String, Int, Double, Bool?) async throws -> Void,
    withdraw: @escaping @Sendable () async throws -> Void
  ) {
    self.saveOnboarding = saveOnboarding
    self.fetchStore = fetchStore
    self.updateStore = updateStore
    self.withdraw = withdraw
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
      },
      fetchStore: {
        let response: BaseResponse<StoreResponse> = try await apiClient.request(
          path: "/api/v1/users/stores",
          method: .get
        )
        guard let data = response.data else {
          throw APIError.decodingError("Missing data")
        }
        return data
      },
      updateStore: { name, employees, laborCost, includeWeeklyHolidayPay in
        let request = UpdateStoreRequest(
          name: name,
          employees: employees,
          laborCost: laborCost,
          includeWeeklyHolidayPay: includeWeeklyHolidayPay
        )
        let _: BaseResponse<EmptyResponse> = try await apiClient.request(
          path: "/api/v1/users/stores",
          method: .patch,
          body: request
        )
      },
      withdraw: {
        try await apiClient.requestVoid(
          path: "/api/v1/users/me",
          method: .delete
        )
        print("✅ Account withdrawal succeeded")
      }
    )
  }()
  
  public static let previewValue = UserRepository(
    saveOnboarding: { _, _, _, _ in
      print("✅ [Preview] Onboarding saved")
    },
    fetchStore: {
      StoreResponse(
        name: "우리 매장",
        employees: 0,
        laborCost: 0,
        rentCost: 0,
        includeWeeklyHolidayPay: false
      )
    },
    updateStore: { _, _, _, _ in
      print("✅ [Preview] Store updated")
    },
    withdraw: {
      print("✅ [Preview] Withdrawal succeeded")
    }
  )
  
  public static let testValue = UserRepository(
    saveOnboarding: { _, _, _, _ in },
    fetchStore: {
      StoreResponse(name: "", employees: 0, laborCost: 0, includeWeeklyHolidayPay: false)
    },
    updateStore: { _, _, _, _ in },
    withdraw: { }
  )
}

public extension DependencyValues {
  var userRepository: UserRepository {
    get { self[UserRepository.self] }
    set { self[UserRepository.self] = newValue }
  }
}
