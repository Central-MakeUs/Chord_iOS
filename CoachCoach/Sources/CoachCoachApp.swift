//
//  CoachCoachApp.swift
//  CoachCoach
//
//  Created by 양승완 on 12/29/25.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

@main
struct CoachCoachApp: App {
  private let appStore = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
  
  init() {
    Pretendard.registerFonts()
  }
  
  var body: some Scene {
    WindowGroup {
      AppEntryView(store: appStore)
        .environment(\.colorScheme, .light)
    }
  }
}
