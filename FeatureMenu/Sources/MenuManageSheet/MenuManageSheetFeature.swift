import ComposableArchitecture

@Reducer
public struct MenuManageSheetFeature {
  public struct State: Equatable {
    var tagText = ""
    var tags: [String] = ["음료", "디저트"]
    var hasChanges = false

    public init() {}
  }

  public enum Action: Equatable {
    case tagTextChanged(String)
    case addTagTapped
    case removeTagTapped(String)
    case completeTapped
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .tagTextChanged(text):
        state.tagText = text
        return .none
      case .addTagTapped:
        let trimmed = state.tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .none }
        if !state.tags.contains(trimmed) {
          state.tags.append(trimmed)
          state.hasChanges = true
        }
        state.tagText = ""
        return .none
      case let .removeTagTapped(tag):
        state.tags.removeAll { $0 == tag }
        state.hasChanges = true
        return .none
      case .completeTapped:
        return .none
      }
    }
  }
}
