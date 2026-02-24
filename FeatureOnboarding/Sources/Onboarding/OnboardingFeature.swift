import ComposableArchitecture
import Foundation
import DataLayer

@Reducer
public struct OnboardingFeature {
  @Dependency(\.userRepository) var userRepository
  public enum Step: Equatable {
    case storeName
    case storeOperation
    case completion
    case menuPrompt
  }

  public struct State: Equatable {
    var step: Step = .storeName
    var storeName: String = ""

    var staffCount: String = ""
    var isSoloWorker: Bool = false
    var laborCost: String = ""
    var includeWeeklyAllowance: Bool = false

    public init() {}

    var formattedLaborCost: String {
      let cleaned = laborCost.replacingOccurrences(of: ",", with: "")
      guard let number = Int(cleaned) else { return laborCost }
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      return (formatter.string(from: NSNumber(value: number)) ?? laborCost) + "원"
    }

    var staffCountDisplay: String {
      guard !staffCount.isEmpty else { return "0명" }
      return staffCount + "명"
    }
  }

  public enum Action: Equatable {
    case storeNameChanged(String)
    case staffCountChanged(String)
    case isSoloWorkerToggled
    case laborCostChanged(String)
    case includeWeeklyAllowanceToggled
    case backTapped
    case primaryTapped
    case saveOnboardingResult(Result<Void, Error>)
    case completionTimerFired
    case menuRegistrationTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finished
      case dismissed
    }
    
    public static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case let (.storeNameChanged(l), .storeNameChanged(r)): return l == r
      case let (.staffCountChanged(l), .staffCountChanged(r)): return l == r
      case (.isSoloWorkerToggled, .isSoloWorkerToggled): return true
      case let (.laborCostChanged(l), .laborCostChanged(r)): return l == r
      case (.includeWeeklyAllowanceToggled, .includeWeeklyAllowanceToggled): return true
      case (.backTapped, .backTapped): return true
      case (.primaryTapped, .primaryTapped): return true
      case (.saveOnboardingResult(.success), .saveOnboardingResult(.success)): return true
      case (.saveOnboardingResult(.failure), .saveOnboardingResult(.failure)): return true
      case (.completionTimerFired, .completionTimerFired): return true
      case (.menuRegistrationTapped, .menuRegistrationTapped): return true
      case let (.delegate(l), .delegate(r)): return l == r
      default: return false
      }
    }
  }

  public init() {}

  private enum CancelID { case completionTimer }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .storeNameChanged(name):
        state.storeName = name
        return .none

      case let .staffCountChanged(count):
        state.staffCount = Self.sanitizedDigits(count)
        return .none

      case .isSoloWorkerToggled:
        state.isSoloWorker.toggle()
        if state.isSoloWorker {
          state.staffCount = "0"
        } else {
          state.staffCount = ""
        }
        return .none

      case let .laborCostChanged(cost):
        state.laborCost = Self.sanitizedDigitsAndCommas(cost)
        return .none

      case .includeWeeklyAllowanceToggled:
        state.includeWeeklyAllowance.toggle()
        return .none

      case .backTapped:
        switch state.step {
        case .storeName:
          return .send(.delegate(.dismissed))
        case .storeOperation:
          state.step = .storeName
        case .completion, .menuPrompt:
          break
        }
        return .none

      case .primaryTapped:
        switch state.step {
        case .storeName:
          state.step = .storeOperation
        case .storeOperation:
          let storeName = state.storeName
          let employees = Int(state.staffCount) ?? 0
          let laborCostCleaned = state.laborCost.replacingOccurrences(of: ",", with: "")
          let laborCost = Double(laborCostCleaned) ?? 0
          let includeWeeklyHolidayPay = state.includeWeeklyAllowance
          
          return .run { send in
            do {
              try await userRepository.saveOnboarding(
                storeName,
                employees,
                laborCost,
                includeWeeklyHolidayPay
              )
              await send(.saveOnboardingResult(.success(())))
            } catch {
              print("❌ Failed to save onboarding: \(error)")
              await send(.saveOnboardingResult(.failure(error)))
            }
          }
        case .completion, .menuPrompt:
          break
        }
        return .none
      
      case .saveOnboardingResult(.success):
        state.step = .completion
        UserDefaults.standard.set(state.storeName, forKey: "storeName")
        UserDefaults.standard.set(Int(state.staffCount) ?? 0, forKey: "employees")
        UserDefaults.standard.set(Int(state.laborCost.replacingOccurrences(of: ",", with: "")) ?? 0, forKey: "laborCost")
        return .run { send in
          try await Task.sleep(for: .seconds(1.5))
          await send(.completionTimerFired)
        }
        .cancellable(id: CancelID.completionTimer)
      
      case .saveOnboardingResult(.failure):
        return .none

      case .completionTimerFired:
        state.step = .menuPrompt
        return .none

      case .menuRegistrationTapped:
        return .send(.delegate(.finished))

      case .delegate:
        return .none
      }
    }
  }
}

private extension OnboardingFeature {
  static func sanitizedDigits(_ value: String) -> String {
    value.filter(\.isNumber)
  }

  static func sanitizedDigitsAndCommas(_ value: String) -> String {
    value.filter { $0.isNumber || $0 == "," }
  }
}
