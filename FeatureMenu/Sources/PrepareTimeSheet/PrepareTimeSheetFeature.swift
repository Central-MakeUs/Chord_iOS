import Foundation
import ComposableArchitecture

@Reducer
public struct PrepareTimeSheetFeature {
  public struct State: Equatable {
    var draftMinutes: Int
    var draftSeconds: Int
    var initialMinutes: Int
    var initialSeconds: Int
    
    public init(minutes: Int, seconds: Int) {
      self.draftMinutes = minutes
      self.draftSeconds = seconds
      self.initialMinutes = minutes
      self.initialSeconds = seconds
    }
    
    var hasChanges: Bool {
      draftMinutes != initialMinutes || draftSeconds != initialSeconds
    }
    
    var formattedTime: String {
      "\(draftMinutes)분 \(draftSeconds)초"
    }
  }
  
  public enum Action: Equatable {
    case minutesChanged(Int)
    case secondsChanged(Int)
    case confirmTapped
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .minutesChanged(minutes):
        state.draftMinutes = minutes
        return .none
        
      case let .secondsChanged(seconds):
        state.draftSeconds = seconds
        return .none
        
      case .confirmTapped:
        return .none
      }
    }
  }
}
