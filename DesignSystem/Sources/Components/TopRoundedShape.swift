//
//  TopRoundedShape.swift
//  CoachCoach
//
//  Created by 양승완 on 1/3/26.
//


import SwiftUI

public struct TopRoundedShape: Shape {
  public var radius: CGFloat = 20
  
  public init(radius: CGFloat = 20) {
    self.radius = radius
  }

  public func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: [.topLeft, .topRight],
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
