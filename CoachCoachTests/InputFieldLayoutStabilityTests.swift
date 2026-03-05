import XCTest
import SwiftUI
import UIKit
import ComposableArchitecture
import DesignSystem
import FeatureMenuRegistration

@MainActor
final class InputFieldLayoutStabilityTests: XCTestCase {
  private var windows: [UIWindow] = []

  override func tearDown() {
    windows.forEach { $0.isHidden = true }
    windows.removeAll()
    super.tearDown()
  }

  func testClearableInputField_TextFieldFrameStableAcrossEmptyAndFilled() {
    let emptyFrame = primaryTextFieldFrame(
      for: ClearableInputField(
        text: .constant(""),
        placeholder: "다른 이름 입력",
        height: 47,
        backgroundColor: .clear
      )
    )

    let filledFrame = primaryTextFieldFrame(
      for: ClearableInputField(
        text: .constant("돌체라떼"),
        placeholder: "다른 이름 입력",
        height: 47,
        backgroundColor: .clear
      )
    )

    assertFrameStable(lhs: emptyFrame, rhs: filledFrame)
  }

  func testPriceInputField_TextFieldFrameStableAcrossEmptyAndFilled() {
    let emptyFrame = primaryTextFieldFrame(
      for: PriceInputField(
        text: .constant(""),
        placeholder: "가격 입력",
        height: 47,
        backgroundColor: .clear
      )
    )

    let filledFrame = primaryTextFieldFrame(
      for: PriceInputField(
        text: .constant("5,600"),
        placeholder: "가격 입력",
        height: 47,
        backgroundColor: .clear
      )
    )

    assertFrameStable(lhs: emptyFrame, rhs: filledFrame)
  }

  func testMenuRegistrationStep1_MenuNameTextFieldFrameStableAcrossEmptyAndFilled() {
    var emptyState = MenuRegistrationFeature.State()
    emptyState.showSuggestions = false

    var filledState = MenuRegistrationFeature.State()
    filledState.menuName = "아메리카노"
    filledState.showSuggestions = false

    let emptyStore = Store(initialState: emptyState) {
      MenuRegistrationFeature()
    }
    let filledStore = Store(initialState: filledState) {
      MenuRegistrationFeature()
    }

    let emptyFrame = primaryTextFieldFrame(
      for: MenuRegistrationStep1View(store: emptyStore)
    )
    let filledFrame = primaryTextFieldFrame(
      for: MenuRegistrationStep1View(store: filledStore)
    )

    assertFrameStable(lhs: emptyFrame, rhs: filledFrame)
  }

  private func primaryTextFieldFrame<V: View>(for rootView: V) -> CGRect {
    let host = UIHostingController(rootView: rootView)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = host
    window.makeKeyAndVisible()
    windows.append(window)

    host.view.frame = window.bounds
    host.view.setNeedsLayout()
    host.view.layoutIfNeeded()

    RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    host.view.layoutIfNeeded()

    let textFields = allTextFields(in: host.view)
    let sorted = textFields.sorted { lhs, rhs in
      let lhsFrame = lhs.convert(lhs.bounds, to: host.view)
      let rhsFrame = rhs.convert(rhs.bounds, to: host.view)
      if abs(lhsFrame.minY - rhsFrame.minY) > 0.5 {
        return lhsFrame.minY < rhsFrame.minY
      }
      return lhsFrame.minX < rhsFrame.minX
    }

    guard let field = sorted.first else {
      XCTFail("UITextField not found in hosted view")
      return .zero
    }
    return field.convert(field.bounds, to: host.view)
  }

  private func allTextFields(in view: UIView) -> [UITextField] {
    var result: [UITextField] = []
    if let field = view as? UITextField {
      result.append(field)
    }
    for subview in view.subviews {
      result.append(contentsOf: allTextFields(in: subview))
    }
    return result
  }

  private func assertFrameStable(lhs: CGRect, rhs: CGRect, accuracy: CGFloat = 0.5) {
    XCTAssertEqual(lhs.minX, rhs.minX, accuracy: accuracy)
    XCTAssertEqual(lhs.width, rhs.width, accuracy: accuracy)
    XCTAssertEqual(lhs.height, rhs.height, accuracy: accuracy)
  }
}
