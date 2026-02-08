import SwiftUI
import ComposableArchitecture
import FeatureMenuRegistration
import DataLayer

@main
struct FeatureMenuRegistrationDemoApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        List {
          Section("Ultrawork") {
            NavigationLink("메뉴 등록 (Step 플로우)") {
              MenuRegistrationView(
                store: Store(initialState: MenuRegistrationFeature.State()) {
                  MenuRegistrationFeature()
                }
              )
            }
          }
          Section("Existing") {
            NavigationLink("기존 메뉴 등록") {
              MenuRegistrationView(
                store: Store(initialState: MenuRegistrationFeature.State()) {
                  MenuRegistrationFeature()
                }
              )
            }
          }
        }
        .navigationTitle("Menu Registration Demo")
      }
      .environment(\.colorScheme, .light)
      .task {
        do {
          print("🔑 [Demo] Attempting Developer Login...")
          try await AuthRepository.liveValue.login("user1", "password123@")
          print("✅ [Demo] Developer Login Successful")
        } catch {
          print("❌ [Demo] Developer Login Failed: \(error)")
        }
      }
    }
  }
}
