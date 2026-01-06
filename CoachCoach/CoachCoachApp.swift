//
//  CoachCoachApp.swift
//  CoachCoach
//
//  Created by 양승완 on 12/29/25.
//

import SwiftUI

@main
struct CoachCoachApp: App {
  @StateObject private var appRouter = AppRouter()
  @StateObject private var menuRouter = MenuRouter()
  @StateObject private var inventoryRouter = InventoryRouter()
  @StateObject private var settingsRouter = SettingsRouter()
  
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.colorScheme, .light)
                .environmentObject(appRouter)
                .environmentObject(menuRouter)
                .environmentObject(inventoryRouter)
                .environmentObject(settingsRouter)
        }
    }
}
