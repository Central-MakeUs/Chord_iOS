//
//  ContentView.swift
//  CoachCoach
//
//  Created by 양승완 on 12/29/25.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject private var appRouter: AppRouter

  var body: some View {
    NavigationStack(path: $appRouter.path) {
      TabView(selection: $appRouter.selectedTab) {
        HomeView()
          .tag(AppTab.home)
          .tabItem {
            VStack(spacing: 2) {
              (appRouter.selectedTab == .home ? Image.homeIconActive : Image.homeIcon)
                .renderingMode(.original)
              Text("홈")
            }
          }
        
        MenuView()
          .tag(AppTab.menu)
          .tabItem {
            VStack(spacing: 2) {
              (appRouter.selectedTab == .menu ? Image.menuIconActive : Image.menuIcon)
                .renderingMode(.original)
              Text("메뉴")
            }
          }
        
        IngredientsView()
          .tag(AppTab.ingredients)
          .tabItem {
            VStack(spacing: 2) {
              (appRouter.selectedTab == .ingredients ? Image.meterialIconActive : Image.meterialIcon)
                .renderingMode(.original)
              Text("재료")
            }
          }
        
        AICoachView()
          .tag(AppTab.aiCoach)
          .tabItem {
            VStack(spacing: 2) {
              (appRouter.selectedTab == .aiCoach ? Image.aiCoachIconActive : Image.aiCoachIcon)
                .renderingMode(.original)
              Text("AI코치")
            }
          }
      }
      .navigationDestination(for: AppRoute.self) { route in
        switch route {
        case .login:
          AppRoutePlaceholderView(title: "로그인")
        case .onboarding:
          AppRoutePlaceholderView(title: "온보딩")
        }
      }
    }
    .tint(AppColor.grayscale900)
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
        .foregroundStyle(AppColor.grayscale900)
    }
  }
}

#Preview {
  MainView()
    .environmentObject(AppRouter())
    .environmentObject(MenuRouter())
    .environmentObject(InventoryRouter())
    .environmentObject(SettingsRouter())
    .environment(\.colorScheme, .light)
}
