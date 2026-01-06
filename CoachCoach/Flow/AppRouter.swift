//
//  AppRouter.swift
//  CoachCoach
//
//  Created by 양승완 on 1/3/26.
//

import Combine
import SwiftUI

enum AppTab: Hashable {
    case home
    case menu
    case ingredients
    case aiCoach
}

@MainActor
final class AppRouter: ObservableObject {

    // 현재 선택된 탭
    @Published var selectedTab: AppTab = .home

    // 전역 push (로그인, 공지, 딥링크 등)
    @Published var path: [AppRoute] = []

    func switchTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum AppRoute: Hashable {
    case login
    case onboarding
}
