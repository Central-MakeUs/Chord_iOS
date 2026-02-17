import ProjectDescription

let project = Project(
  name: "CoachCoach",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9",
      "MARKETING_VERSION": "0.0.1",
      "CURRENT_PROJECT_VERSION": "1"
    ]
  ),
  targets: [
    .target(
      name: "CoachCoach",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.seungwan.coachcoach",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .file(path: "Info.plist"),
      sources: ["Sources/**"],
      resources: [
        "Assets.xcassets",
        "Resources/App.config",
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
      ],
      settings: .settings(
        configurations: [
          .debug(
            name: .debug,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Automatic",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER": "",
              "INFOPLIST_KEY_CFBundleDisplayName": "코치코치",
              "INFOPLIST_KEY_CFBundlePackageType": "APPL",
              "PRODUCT_BUNDLE_IDENTIFIER": "com.seungwan.coachcoach"
            ]
          ),
          .release(
            name: .release,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Manual",
              "CODE_SIGN_IDENTITY": "Apple Distribution",
              "PROVISIONING_PROFILE_SPECIFIER": "CoachCoach AppStore (Manual)",
              "INFOPLIST_KEY_CFBundleDisplayName": "코치코치",
              "INFOPLIST_KEY_CFBundlePackageType": "APPL",
              "PRODUCT_BUNDLE_IDENTIFIER": "com.seungwan.coachcoach"
            ]
          )
        ]
      )
    ),
    .target(
      name: "CoachCoachTests",
      destinations: [.iPhone],
      product: .unitTests,
      bundleId: "com.seungwan.CoachCoachTests",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["../CoachCoachTests/**"],
      dependencies: [.target(name: "CoachCoach")],
      settings: .settings(
        configurations: [
          .debug(
            name: .debug,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Automatic",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER": ""
            ]
          ),
          .release(
            name: .release,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Automatic",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER": ""
            ]
          )
        ]
      )
    ),
    .target(
      name: "CoachCoachUITests",
      destinations: [.iPhone],
      product: .uiTests,
      bundleId: "com.seungwan.CoachCoachUITests",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["../CoachCoachUITests/**"],
      dependencies: [.target(name: "CoachCoach")],
      settings: .settings(
        configurations: [
          .debug(
            name: .debug,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Automatic",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER": ""
            ]
          ),
          .release(
            name: .release,
            settings: [
              "DEVELOPMENT_TEAM": "YH4A87H8M4",
              "CODE_SIGN_STYLE": "Automatic",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "PROVISIONING_PROFILE_SPECIFIER": ""
            ]
          )
        ]
      )
    )
  ]
)
