import ProjectDescription

let demoInfoPlist: InfoPlist = .extendingDefault(with: [
  "UIAppFonts": [
    "Pretendard-Black.otf",
    "Pretendard-ExtraBold.otf",
    "Pretendard-Bold.otf",
    "Pretendard-SemiBold.otf",
    "Pretendard-Medium.otf",
    "Pretendard-Regular.otf",
    "Pretendard-Light.otf",
    "Pretendard-ExtraLight.otf",
    "Pretendard-Thin.otf",
    "PretendardVariable.ttf"
  ],
  "UIApplicationSceneManifest": [
    "UIApplicationSupportsMultipleScenes": false,
    "UISceneConfigurations": [
      "UIWindowSceneSessionRoleApplication": [
        [
          "UISceneConfigurationName": "Default Configuration",
          "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
        ]
      ]
    ]
  ],
  "UILaunchStoryboardName": "LaunchScreen",
  "NSAppTransportSecurity": [
    "NSAllowsArbitraryLoads": true
  ]
])


let project = Project(
  name: "FeatureMenuRegistration",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "6.0",
      "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
      "SWIFT_NONISOLATED_NONSENDING_BY_DEFAULT": "YES",
      "SWIFT_STRICT_CONCURRENCY": "minimal"
    ]
  ),
  targets: [
    .target(
      name: "FeatureMenuRegistration",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.FeatureMenuRegistration",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "DesignSystem", path: "../DesignSystem"),
        .project(target: "DataLayer", path: "../DataLayer"),
        .project(target: "CoreModels", path: "../CoreModels"),
        .external(name: "ComposableArchitecture")
      ],
      settings: .settings(
        base: [
          "SWIFTUI_PREVIEW_HOST_APPLICATION": "$(BUILT_PRODUCTS_DIR)/FeatureMenuRegistrationDemo.app/FeatureMenuRegistrationDemo"
        ]
      )
    ),
    .target(
      name: "FeatureMenuRegistrationDemo",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.seungwan.CoachCoach.FeatureMenuRegistrationDemo",
      deploymentTargets: .iOS("17.0"),
      infoPlist: demoInfoPlist,
      sources: ["Demo/Sources/**"],
      resources: [
        "../CoachCoach/Assets.xcassets",
        "../CoachCoach/Resources/Assets.xcassets",
        "../CoachCoach/Resources/Fonts/**"
      ],
      dependencies: [
        .target(name: "FeatureMenuRegistration"),
        .project(target: "DataLayer", path: "../DataLayer"),
        .external(name: "ComposableArchitecture")
      ],
      settings: .settings(
        base: [
          "ENABLE_DEBUG_DYLIB": "YES"
        ]
      )
    )
  ]
)
