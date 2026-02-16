import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MenuRegistrationView: View {
  let store: StoreOf<MenuRegistrationFeature>
  let onMenuCreated: () -> Void

  public init(
    store: StoreOf<MenuRegistrationFeature>,
    onMenuCreated: @escaping () -> Void = {}
  ) {
    self.store = store
    self.onMenuCreated = onMenuCreated
  }

  private struct ViewState: Equatable {
    let currentStep: MenuRegistrationFeature.Step
    let isNavigatingForward: Bool
    let isMenuCreated: Bool
    
    init(state: MenuRegistrationFeature.State) {
      self.currentStep = state.currentStep
      self.isNavigatingForward = state.isNavigatingForward
      self.isMenuCreated = state.isMenuCreated
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
      .onChange(of: viewStore.isMenuCreated) { _, isCreated in
        guard isCreated else { return }
        onMenuCreated()
        viewStore.send(.menuCreatedHandled)
      }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .toolbar(.hidden, for: .tabBar)
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
