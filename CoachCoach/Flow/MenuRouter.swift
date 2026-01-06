//
//  MenuRoute.swift
//  CoachCoach
//
//  Created by 양승완 on 1/3/26.
//


import SwiftUI
import Combine

enum MenuRoute: Hashable {
    case detail(MenuItem)
    case add
    case edit(MenuItem)
}

@MainActor
final class MenuRouter: ObservableObject {

    @Published var path: [MenuRoute] = []

    func pushDetail(item: MenuItem) {
        path.append(.detail(item))
    }

    func pushAdd() {
        path.append(.add)
    }

    func pushEdit(item: MenuItem) {
        path.append(.edit(item))
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
