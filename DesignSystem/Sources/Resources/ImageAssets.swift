import SwiftUI
import UIKit

private let designSystemBundle = Bundle(identifier: "com.seungwan.CoachCoach.DesignSystem") ?? Bundle.main

private func bundledImage(
  primaryName: String,
  bundle: Bundle,
  fallbacks: [String] = [],
  systemFallback: String = "questionmark.square"
) -> Image {
  let names = [primaryName] + fallbacks

  for name in names {
    if UIImage(named: name, in: bundle, compatibleWith: nil) != nil {
      return Image(name, bundle: bundle)
    }
  }

  for name in names {
    if UIImage(named: name, in: .main, compatibleWith: nil) != nil {
      return Image(name, bundle: .main)
    }
  }

  return Image(systemName: systemFallback)
}

public extension Image {
  static let arrowLeftIcon = Image("ArrowLeftIcon", bundle: designSystemBundle)
  static let arrowRightIcon = Image("ArrowRightIcon", bundle: designSystemBundle)
  static let aiCoachIcon = Image("AIcoachIcon", bundle: designSystemBundle)
  static let aiCoachIconActive = Image("AIcoachIconActive", bundle: designSystemBundle)
  static let caretDownIcon = Image("CaretDownpIcon", bundle: designSystemBundle)
  static let caretUpIcon = Image("CaretUpIcon", bundle: designSystemBundle)
  static let cancelRoundedIcon = Image("CancelRoundedIcon", bundle: designSystemBundle)
  static let chevronDownOutlineIcon = Image("ChevronDownOutlineIcon", bundle: designSystemBundle)
  static let chevronLeftOutlineIcon = Image("ChevronLeftOutlineIcon", bundle: designSystemBundle)
  static let chevronRightOutlineIcon = Image("ChevronRightOutlineIcon", bundle: designSystemBundle)
  static let chevronUpOutlineIcon = Image("ChevronUpOutlineIcon", bundle: designSystemBundle)
  static let homeIcon = Image("HomeIcon", bundle: designSystemBundle)
  static let homeIconActive = Image("HomeIconActive", bundle: designSystemBundle)
  static let infoFilledIcon = bundledImage(
    primaryName: "InfoFilledIcon",
    bundle: designSystemBundle,
    fallbacks: ["InfoFilledIcon.svg"],
    systemFallback: "info.circle.fill"
  )

  static let infoOutlinedIcon = bundledImage(
    primaryName: "InfoFOutlinedIcon",
    bundle: designSystemBundle,
    fallbacks: ["InfoFOutlinedIcon.svg"],
    systemFallback: "info.circle"
  )
  static let bellIcon = Image("BellIcon", bundle: designSystemBundle)
  static let eyeIcon = Image("EyeIcon", bundle: designSystemBundle)
  static let eyeOffIcon = Image("EyeOffIcon", bundle: designSystemBundle)
  static let gearIcon = Image("GearIcon", bundle: designSystemBundle)
  static let meatballIcon = Image("MeatballIcon", bundle: designSystemBundle)
  static let menuRoundedIcon = Image("MenuRoundedIcon", bundle: designSystemBundle)
  static let menuIcon = Image("MenuIcon", bundle: designSystemBundle)
  static let menuIconActive = Image("MenuIconActive", bundle: designSystemBundle)
  static let meterialIcon = Image("MeterialIcon", bundle: designSystemBundle)
  static let meterialIconActive = Image("MeterialIconActive", bundle: designSystemBundle)
  static let plusIcon = Image("PlusIcon", bundle: designSystemBundle)
  static let plusCircleBlueIcon = Image("PlusCircleBlueIcon", bundle: designSystemBundle)
  static let radioIcon = Image("Radio", bundle: designSystemBundle)
  static let radioUnselectedIcon = Image("RadioUnselected", bundle: Bundle.main)
  static let searchIcon = Image("SearchIcon", bundle: designSystemBundle)
  static let slotIcon = Image("SlotIcon", bundle: designSystemBundle)
  static let starIcon = Image("StarIcon", bundle: designSystemBundle)
  static let starFilledIcon = Image("StarFilledIcon", bundle: designSystemBundle)
  static let pencleIcon = Image("PencleIcon", bundle: designSystemBundle)
  static let checkmarkIcon = Image("CheckmarkIcon", bundle: Bundle.main)
  static let checkBoxCircleIcon = Image("CheckBoxCircleIcon", bundle: designSystemBundle)
  static let checkBoxCircleCheckedIcon = Image("CheckBoxCircleCheckedIcon", bundle: designSystemBundle)
  static let aiCoachDiagnosisIcon = Image("AICoachDiagnosisIcon", bundle: designSystemBundle)
  static let aiCoachActionGuideIcon = Image("AICoachActionGuideIcon", bundle: designSystemBundle)
  static let aiCoachExpectedEffectIcon = Image("AICoachExpectedEffectIcon", bundle: designSystemBundle)
  static let trashIcon = Image("TrashIcon", bundle: Bundle.main)
  static let speechBubbleTail = Image("SpeechBubbleTail", bundle: Bundle.main)
  static let coachCoachLogo = Image("CoachCoachLogo", bundle: Bundle.main)
  static let strategyCompletionGraphic = Image("StrategyCompletionGraphic", bundle: Bundle.main)
}
