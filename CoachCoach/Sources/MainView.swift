import SwiftUI
import ComposableArchitecture
import CoreCommon
import CoreModels
import DesignSystem
import FeatureAICoach
import FeatureHome
import FeatureIngredients
import FeatureMenu
import FeatureMenuRegistration

struct MainView: View {
  let store: StoreOf<MainFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack(
        path: viewStore.binding(
          get: \.path,
          send: MainFeature.Action.pathChanged
        )
      ) {
        tabs(viewStore)
          .tint(AppColor.grayscale900)
          .navigationDestination(for: HomeRoute.self) { route in
            homeDestination(route, viewStore: viewStore)
          }
          .navigationDestination(for: MenuRoute.self) { menuDestination($0) }
          .navigationDestination(for: IngredientsRoute.self) { ingredientsDestination($0) }
      }
      .onAppear {
        viewStore.send(.selectedTabChanged(.home))
      }
    }
  }

  @ViewBuilder
  private func tabs(_ viewStore: ViewStoreOf<MainFeature>) -> some View {
    TabView(
      selection: viewStore.binding(
        get: \.selectedTab,
        send: MainFeature.Action.selectedTabChanged
      )
    ) {
      IfLetStore(store.scope(state: \.home, action: \.home)) { homeStore in
        HomeView(store: homeStore)
      } else: {
        AppRoutePlaceholderView(title: "홈 로딩 중...")
      }
      .tag(AppTab.home)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .home ? Image.homeIconActive : Image.homeIcon)
            .renderingMode(.original)
          Text("홈")
        }
      }

      IfLetStore(store.scope(state: \.menu, action: \.menu)) { menuStore in
        MenuView(store: menuStore)
      } else: {
        AppRoutePlaceholderView(title: "메뉴 로딩 중...")
      }
      .tag(AppTab.menu)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .menu ? Image.menuIconActive : Image.menuIcon)
            .renderingMode(.original)
          Text("메뉴")
        }
      }

      IfLetStore(store.scope(state: \.ingredients, action: \.ingredients)) { ingredientsStore in
        IngredientsView(store: ingredientsStore)
      } else: {
        AppRoutePlaceholderView(title: "재료 로딩 중...")
      }
      .tag(AppTab.ingredients)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .ingredients ? Image.meterialIconActive : Image.meterialIcon)
            .renderingMode(.original)
          Text("재료")
        }
      }

      IfLetStore(store.scope(state: \.aiCoach, action: \.aiCoach)) { aiCoachStore in
        AICoachView(store: aiCoachStore)
      } else: {
        AppRoutePlaceholderView(title: "AI코치 로딩 중...")
      }
      .tag(AppTab.aiCoach)
      .tabItem {
        VStack(spacing: 2) {
          (viewStore.selectedTab == .aiCoach ? Image.aiCoachIconActive : Image.aiCoachIcon)
            .renderingMode(.original)
          Text("AI코치")
        }
      }
    }
  }

  @ViewBuilder
  private func homeDestination(_ route: HomeRoute, viewStore: ViewStoreOf<MainFeature>) -> some View {
    switch route {
    case .settings:
      HomeSettingsView(onLogoutConfirmed: {
        viewStore.send(.logoutTapped)
      })
    case .weeklyGuide:
      WeeklyGuideDetailView()
    case .resolvedHistory:
      ResolvedHistoryView()
    }
  }

  @ViewBuilder
  private func menuDestination(_ route: MenuRoute) -> some View {
    switch route {
    case let .detail(item):
      MenuDetailView(
        store: Store(initialState: MenuDetailFeature.State(item: item)) {
          MenuDetailFeature()
        }
      )
    case .add:
      MenuRegistrationView(
        store: Store(initialState: MenuRegistrationFeature.State()) {
          MenuRegistrationFeature()
        }
      )
    case let .edit(item):
      MenuEditView(
        store: Store(initialState: MenuEditFeature.State(item: item)) {
          MenuEditFeature()
        }
      )
    case let .ingredients(menuId, menuName, ingredients):
      MenuIngredientsView(
        store: Store(
          initialState: MenuIngredientsFeature.State(
            menuId: menuId,
            menuName: menuName,
            ingredients: ingredients
          )
        ) {
          MenuIngredientsFeature()
        }
      )
    }
  }

  @ViewBuilder
  private func ingredientsDestination(_ route: IngredientsRoute) -> some View {
    switch route {
    case let .detail(item):
      IngredientDetailView(
        store: Store(initialState: IngredientDetailFeature.State(item: item)) {
          IngredientDetailFeature()
        }
      )
    case .add:
      EmptyView()
    case .search:
      IngredientSearchView(
        store: Store(initialState: IngredientSearchFeature.State()) {
          IngredientSearchFeature()
        }
      )
    }
  }
}

private struct WeeklyGuideDetailView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100.ignoresSafeArea()
    }
  }
}

private struct ResolvedHistoryView: View {
  var body: some View {
    ZStack {
      AppColor.grayscale100.ignoresSafeArea()
    }
  }
}

private struct AppRoutePlaceholderView: View {
  let title: String

  var body: some View {
    ZStack {
      AppColor.grayscale100
        .ignoresSafeArea()
      Text(title)
        .font(.pretendardTitle1)
        .foregroundColor(AppColor.grayscale900)
    }
  }
}

#Preview {
  MainView(
    store: Store(initialState: MainFeature.State()) {
      MainFeature()
    }
  )
  .environment(\.colorScheme, .light)
}
