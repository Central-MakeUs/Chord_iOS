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
            NavigationLink("메뉴 등록 Step 1") {
              MenuRegistrationStep1View()
            }
            NavigationLink("메뉴 등록 Step 2") {
              MenuRegistrationStep2View()
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
