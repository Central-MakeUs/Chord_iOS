import ComposableArchitecture

@Reducer
public struct OnboardingFeature {
  public enum Step: Equatable {
    case storeName
    case address
    case confirm
  }

  public struct State: Equatable {
    var step: Step = .storeName
    var storeName: String = ""
    var address: String = ""
    var detailAddress: String = ""
    var staffCount: Int = 3
    var isDetailAddressPresented = false
    var isStaffCountPresented = false

    public init() {}
  }

  public enum Action: Equatable {
    case storeNameChanged(String)
    case addressChanged(String)
    case detailAddressChanged(String)
    case staffCountChanged(Int)
    case backTapped
    case primaryTapped
    case detailAddressPresented(Bool)
    case staffCountPresented(Bool)
    case staffCountSheetCompleted
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finished
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .storeNameChanged(name):
        state.storeName = name
        return .none
      case let .addressChanged(address):
        state.address = address
        return .none
      case let .detailAddressChanged(detail):
        state.detailAddress = detail
        return .none
      case let .staffCountChanged(count):
        state.staffCount = count
        return .none
      case .backTapped:
        switch state.step {
        case .storeName:
          break
        case .address:
          state.step = .storeName
        case .confirm:
          state.step = .address
        }
        return .none
      case .primaryTapped:
        switch state.step {
        case .storeName:
          state.step = .address
        case .address:
          state.step = .confirm
        case .confirm:
          state.isStaffCountPresented = true
        }
        return .none
      case let .detailAddressPresented(isPresented):
        state.isDetailAddressPresented = isPresented
        return .none
      case let .staffCountPresented(isPresented):
        state.isStaffCountPresented = isPresented
        return .none
      case .staffCountSheetCompleted:
        state.isStaffCountPresented = false
        return .send(.delegate(.finished))
      case .delegate:
        return .none
      }
    }
  }
}
