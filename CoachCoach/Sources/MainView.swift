//
//  ContentView.swift
//  CoachCoach
//
//  Created by 양승완 on 12/29/25.
//

import SwiftUI
import ComposableArchitecture
import CoreCommon
import DesignSystem
import FeatureAICoach
import FeatureHome
import FeatureIngredients
import FeatureMenu

struct MainView: View {
  let store: StoreOf<MainFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
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
      .tint(AppColor.grayscale900)
      .onAppear {
        // Initialize the default tab (home) when view appears
        viewStore.send(.selectedTabChanged(.home))
      }
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
