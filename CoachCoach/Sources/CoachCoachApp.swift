//
//  CoachCoachApp.swift
//  CoachCoach
//
//  Created by 양승완 on 12/29/25.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import UIKit

@main
struct CoachCoachApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  private let appStore = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
  
  init() {
    Pretendard.registerFonts()

    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithDefaultBackground()
    tabBarAppearance.backgroundColor = .white

    UITabBar.appearance().standardAppearance = tabBarAppearance
    if #available(iOS 15.0, *) {
      UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
  }
  
  var body: some Scene {
    WindowGroup {
      AppEntryView(store: appStore)
        .environment(\.colorScheme, .light)
    }
  }
}
