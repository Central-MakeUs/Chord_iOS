import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationView: View {
  let store: StoreOf<MenuRegistrationFeature>

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: \.currentStep) { viewStore in
      ZStack {
        switch viewStore.state {
        case .step1:
          MenuRegistrationStep1View(store: store)
            .transition(.asymmetric(
              insertion: .move(edge: .leading).combined(with: .opacity),
              removal: .move(edge: .leading).combined(with: .opacity)
            ))
        case .step2:
          MenuRegistrationStep2View(store: store)
            .transition(.asymmetric(
              insertion: .move(edge: .trailing).combined(with: .opacity),
              removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        }
      }
      .animation(.easeInOut(duration: 0.3), value: viewStore.state)
    }
  }
}

#Preview {
  MenuRegistrationView(
    store: Store(initialState: MenuRegistrationFeature.State()) {
      MenuRegistrationFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
