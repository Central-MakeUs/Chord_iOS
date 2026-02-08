import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationView: View {
  let store: StoreOf<MenuRegistrationFeature>

  public init(store: StoreOf<MenuRegistrationFeature>) {
    self.store = store
  }

  private struct ViewState: Equatable {
    let currentStep: MenuRegistrationFeature.Step
    let isNavigatingForward: Bool
    
    init(state: MenuRegistrationFeature.State) {
      self.currentStep = state.currentStep
      self.isNavigatingForward = state.isNavigatingForward
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      let isForward = viewStore.isNavigatingForward
      ZStack {
        switch viewStore.currentStep {
        case .step1:
          MenuRegistrationStep1View(store: store)
            .transition(.asymmetric(
              insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
              removal: .move(edge: isForward ? .leading : .trailing).combined(with: .opacity)
            ))
        case .step2:
          MenuRegistrationStep2View(store: store)
            .transition(.asymmetric(
              insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
              removal: .move(edge: isForward ? .leading : .trailing).combined(with: .opacity)
            ))
        case .confirmation:
          MenuRegistrationConfirmationView(store: store)
            .transition(.asymmetric(
              insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
              removal: .move(edge: isForward ? .leading : .trailing).combined(with: .opacity)
            ))
        }
      }
      .animation(.easeInOut(duration: 0.3), value: viewStore.currentStep)
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .hideTabBar(true)
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
