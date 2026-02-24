import ComposableArchitecture
import CoreCommon
import FeatureAICoach
import FeatureHome
import FeatureIngredients
import FeatureMenu
import SwiftUI
import UIKit

@Reducer
struct MainFeature {
  struct State: Equatable {
    var selectedTab: AppTab = .home
    var path = NavigationPath()
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
    
    static func == (lhs: State, rhs: State) -> Bool {
      lhs.selectedTab == rhs.selectedTab &&
      lhs.home == rhs.home &&
      lhs.menu == rhs.menu &&
      lhs.ingredients == rhs.ingredients &&
      lhs.aiCoach == rhs.aiCoach &&
      lhs.path.count == rhs.path.count
    }
  }

  enum Action: Equatable {
    case selectedTabChanged(AppTab)
    case pathChanged(NavigationPath)
    case logoutTapped
    case withdrawalTapped
    case home(HomeFeature.Action)
    case menu(MenuFeature.Action)
    case ingredients(IngredientsFeature.Action)
    case aiCoach(AICoachFeature.Action)
    
    static func == (lhs: Action, rhs: Action) -> Bool {
      switch (lhs, rhs) {
      case let (.selectedTabChanged(l), .selectedTabChanged(r)): return l == r
      case (.pathChanged, .pathChanged): return true // NavigationPath 비교 어려움
      case (.logoutTapped, .logoutTapped): return true
      case (.withdrawalTapped, .withdrawalTapped): return true
      case (.home(let l), .home(let r)): return l == r
      case (.menu(let l), .menu(let r)): return l == r
      case (.ingredients(let l), .ingredients(let r)): return l == r
      case (.aiCoach(let l), .aiCoach(let r)): return l == r
      default: return false
      }
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      print("🔵 MainFeature received action: \(action)")
      switch action {
      case let .selectedTabChanged(tab):
        print("🔵 Tab changed to: \(tab)")
        let previousTab = state.selectedTab
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
        return previousTab != tab ? selectionHaptic() : .none
        
      case let .pathChanged(path):
        state.path = path
        return .none

      case .logoutTapped:
        return .none

      case .withdrawalTapped:
        return .none

      case .home(.delegate(.openAICoachTab)):
        return .send(.selectedTabChanged(.aiCoach))

      case .home(.delegate(.openWeeklyGuide)):
        state.path.append(HomeRoute.weeklyGuide)
        return .none
        
      case .home:
        return .none
        
      case .menu(.navigateTo(let route)):
        state.path.append(route)
        return .none
        
      case .menu(.addMenuTapped):
        state.path.append(MenuRoute.add)
        return .none
        
      case .menu(.popToRoot):
        state.path = NavigationPath()
        return .none
        
      case .menu:
        return .none
        
      case .ingredients(.searchButtonTapped):
        state.path.append(IngredientsRoute.search)
        return .none
        
      case .ingredients(.addIngredientTapped):
        return .none
        
      case .ingredients:
        return .none
        
      case .aiCoach:
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

  private func selectionHaptic() -> Effect<Action> {
    .run { _ in
      await MainActor.run {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
      }
    }
  }
}
