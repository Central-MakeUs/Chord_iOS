import ComposableArchitecture
import Combine

public enum MenuRouteAction: Equatable {
  case push(MenuRoute)
  case pop
  case popToRoot
}

public struct MenuRouterClient {
  public var push: (MenuRoute) -> Void
  public var pop: () -> Void
  public var popToRoot: () -> Void
  public var routePublisher: AnyPublisher<MenuRouteAction, Never>
}

extension MenuRouterClient: DependencyKey {
  public static var liveValue: MenuRouterClient = {
    let subject = PassthroughSubject<MenuRouteAction, Never>()
    return Self(
      push: { route in subject.send(.push(route)) },
      pop: { subject.send(.pop) },
      popToRoot: { subject.send(.popToRoot) },
      routePublisher: subject.eraseToAnyPublisher()
    )
  }()
}

public extension DependencyValues {
  var menuRouter: MenuRouterClient {
    get { self[MenuRouterClient.self] }
    set { self[MenuRouterClient.self] = newValue }
  }
}
