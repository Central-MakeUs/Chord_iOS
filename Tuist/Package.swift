// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .framework,
    "Dependencies": .framework,
    "IdentifiedCollections": .framework,
    "OrderedCollections": .framework,
    "Perception": .framework,
    "PerceptionCore": .framework,
    "CasePaths": .framework,
    "CasePathsCore": .framework,
    "CustomDump": .framework,
    "XCTestDynamicOverlay": .framework,
    "IssueReporting": .framework,
    "IssueReportingPackageSupport": .framework,
    "Clocks": .framework,
    "CombineSchedulers": .framework,
    "ConcurrencyExtras": .framework,
    "SwiftNavigation": .framework,
    "SwiftUINavigation": .framework,
    "UIKitNavigation": .framework,
    "UIKitNavigationShim": .framework,
    "Sharing": .framework,
    "Sharing1": .framework,
    "Sharing2": .framework,
    "InternalCollectionsUtilities": .framework
  ]
)
#endif

let package = Package(
  name: "CoachCoachDependencies",
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      from: "1.11.0"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      from: "12.9.0"
    )
  ]
)
