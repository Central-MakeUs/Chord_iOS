import SwiftUI
import ComposableArchitecture
import FeatureMenuRegistration

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
    }
  }
}
