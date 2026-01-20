import ComposableArchitecture
import Combine

public struct MenuRouterClient {
  public var push: (MenuRoute) -> Void
  public var routePublisher: AnyPublisher<MenuRoute, Never>
}

extension MenuRouterClient: DependencyKey {
  public static var liveValue: MenuRouterClient = {
    let subject = PassthroughSubject<MenuRoute, Never>()
    return Self(
      push: { route in subject.send(route) },
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
