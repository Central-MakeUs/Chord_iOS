import ComposableArchitecture
import CoreCommon
import FeatureAICoach
import FeatureHome
import FeatureIngredients
import FeatureMenu

@Reducer
struct MainFeature {
  struct State: Equatable {
    var selectedTab: AppTab = .home
    var home: HomeFeature.State?
    var menu: MenuFeature.State?
    var ingredients: IngredientsFeature.State?
    var aiCoach: AICoachFeature.State?


    init() {
      print("🔵 MainFeature.State init - creating home state only")
      self.home = HomeFeature.State()
      self.menu = nil
      self.ingredients = nil
      self.aiCoach = nil
      print("🔵 MainFeature.State init - done")
    }
  }

  enum Action: Equatable {
    case selectedTabChanged(AppTab)
    case home(HomeFeature.Action)
    case menu(MenuFeature.Action)
    case ingredients(IngredientsFeature.Action)
    case aiCoach(AICoachFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      print("🔵 MainFeature received action: \(action)")
      switch action {
      case let .selectedTabChanged(tab):
        print("🔵 Tab changed to: \(tab)")
        state.selectedTab = tab

        // Lazy initialization when tab is selected
        switch tab {
        case .home:
          if state.home == nil {
            print("🔵 Lazy initializing home")
            state.home = HomeFeature.State()
          }
        case .menu:
          if state.menu == nil {
            print("🔵 Lazy initializing menu")
            state.menu = MenuFeature.State()
          }
        case .ingredients:
          if state.ingredients == nil {
            print("🔵 Lazy initializing ingredients")
            state.ingredients = IngredientsFeature.State()
          }
        case .aiCoach:
          if state.aiCoach == nil {
            print("🔵 Lazy initializing aiCoach")
            state.aiCoach = AICoachFeature.State()
          }
        }
        return .none
      case .home:
        print("🔵 Home action received")
        return .none
      case .menu:
        print("🔵 Menu action received")
        return .none
      case .ingredients:
        print("🔵 Ingredients action received")
        return .none
      case .aiCoach:
        print("🔵 AICoach action received")
        return .none
      }
    }

    .ifLet(\.home, action: \.home) {
      HomeFeature()
    }
    .ifLet(\.menu, action: \.menu) {
      MenuFeature()
    }
    .ifLet(\.ingredients, action: \.ingredients) {
      IngredientsFeature()
    }
    .ifLet(\.aiCoach, action: \.aiCoach) {
      AICoachFeature()
    }
  }
}
