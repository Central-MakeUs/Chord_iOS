import ProjectDescription

let project = Project(
  name: "CoachCoach",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "CoachCoach",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.seungwan.CoachCoach",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .file(path: "Info.plist"),
      sources: ["Sources/**"],
      resources: [
        "Assets.xcassets",
        "Resources/Assets.xcassets",
        "Resources/Fonts/**",
        "Resources/LaunchScreen.storyboard"
      ],
      dependencies: [
        .project(target: "CoreCommon", path: "../CoreCommon"),
        .project(target: "CoreModels", path: "../CoreModels"),
        .project(target: "DesignSystem", path: "../DesignSystem"),
        .project(target: "FeatureAICoach", path: "../FeatureAICoach"),
        .project(target: "FeatureHome", path: "../FeatureHome"),
        .project(target: "FeatureIngredients", path: "../FeatureIngredients"),
        .project(target: "FeatureMenu", path: "../FeatureMenu"),
        .project(target: "FeatureMenuRegistration", path: "../FeatureMenuRegistration"),
        .project(target: "FeatureOnboarding", path: "../FeatureOnboarding"),
        .external(name: "ComposableArchitecture")
      ]
    ),
    .target(
      name: "CoachCoachTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "com.seungwan.CoachCoachTests",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["../CoachCoachTests/**"],
      dependencies: [.target(name: "CoachCoach")]
    ),
    .target(
      name: "CoachCoachUITests",
      destinations: [.iPhone],
      product: .uiTests,
      bundleId: "com.seungwan.CoachCoachUITests",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["../CoachCoachUITests/**"],
      dependencies: [.target(name: "CoachCoach")]
    )
  ]
)
