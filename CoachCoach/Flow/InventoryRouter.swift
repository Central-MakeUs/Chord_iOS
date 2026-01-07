//
//  InventoryRoute.swift
//  CoachCoach
//
//  Created by 양승완 on 1/3/26.
//


import SwiftUI
import Combine

enum InventoryRoute: Hashable {
    case detail(InventoryIngredientItem)
    case add
}

@MainActor
final class InventoryRouter: ObservableObject {

    @Published var path: [InventoryRoute] = []

    func pushDetail(item: InventoryIngredientItem) {
        path.append(.detail(item))
    }

    func pushAdd() {
        path.append(.add)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
