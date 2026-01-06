//
//  SettingsRoute.swift
//  CoachCoach
//
//  Created by 양승완 on 1/3/26.
//


import SwiftUI
import Combine

enum SettingsRoute: Hashable {
    case settings
    case weeklyGuide
    case resolvedHistory
}

@MainActor
final class SettingsRouter: ObservableObject {

    @Published var path: [SettingsRoute] = []

    func push(_ route: SettingsRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
