# Code Conventions

## Naming

### Modules (Tuist)
```
Feature[Name]       # e.g., FeatureMenu
Core[Name]          # e.g., CoreModels
[Name]Layer         # e.g., DataLayer
DesignSystem
```

### TCA Components
| Type | Pattern | Example |
|------|---------|---------|
| Feature | `{Name}Feature` | `MenuDetailFeature` |
| View | `{Name}View` | `MenuDetailView` |
| State | `State` (nested) | `MenuDetailFeature.State` |
| Action | `Action` (nested) | `MenuDetailFeature.Action` |
| Reducer | `body` (var) | `var body: some ReducerOf<Self>` |
| Client (Dependency) | `{Name}Client` | `MenuClient` |

### Functions (Action Cases)
- **User Interactions**: `camelCase` + `Tapped` / `Changed` / `Swiped`
  - `saveButtonTapped`, `textChanged(String)`
- **Lifecycle**: `onAppear`, `onDisappear`
- **Delegate (Child -> Parent)**: `delegate(...)`
  - `delegate(.saveCompleted)`
- **Internal/Response**: `response(...)` or `internalAction`
  - `menuResponse(TaskResult<MenuItem>)`

## Architecture Patterns

### The Composable Architecture (TCA)

1. **State**: Data representing the state of the feature
2. **Action**: All possible events (User, System, Delegate)
3. **Reducer**: Logic to evolve state and return effects
4. **Environment (Dependencies)**: Side effects (API, Disk, Time, UUID)

```swift
@Reducer
public struct MenuDetailFeature {
  public struct State: Equatable {
    var item: MenuItem
  }

  public enum Action: Equatable {
    case onAppear
    case saveTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case saveCompleted
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      case .saveTapped:
        return .send(.delegate(.saveCompleted))
      case .delegate:
        return .none
      }
    }
  }
}
```

## File Structure

### Feature Module Structure
```
FeatureMenu/
├── Sources/
│   ├── MenuDetail/
│   │   ├── MenuDetailFeature.swift   # Reducer & Domain
│   │   └── MenuDetailView.swift      # SwiftUI View
│   ├── MenuList/
│   │   ├── MenuListFeature.swift
│   │   └── MenuListView.swift
│   └── FeatureMenuInterface.swift    # Public Interface
├── Tests/
├── Resources/
└── Project.swift                     # Tuist Config
```

## Best Practices

1. **Colocation**: Feature, View, State, Action should be close (often same file or folder).
2. **Explicit Side Effects**: All side effects must go through `Dependency` system.
3. **Exhaustive Testing**: Test all state changes and effects using `TestStore`.
4. **ViewState Pattern**: If State is complex, expose a simplified `ViewState` to the View.
