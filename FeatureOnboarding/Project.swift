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
  "UILaunchStoryboardName": "LaunchScreen"
])


let project = Project(
  name: "FeatureOnboarding",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "FeatureOnboarding",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.FeatureOnboarding",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "DesignSystem", path: "../DesignSystem"),
        .external(name: "ComposableArchitecture")
      ],
      settings: .settings(
        base: [
          "SWIFTUI_PREVIEW_HOST_APPLICATION": "$(BUILT_PRODUCTS_DIR)/FeatureOnboardingDemo.app/FeatureOnboardingDemo"
        ]
      )
    ),
    .target(
      name: "FeatureOnboardingDemo",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.seungwan.CoachCoach.FeatureOnboardingDemo",
      deploymentTargets: .iOS("17.0"),
      infoPlist: demoInfoPlist,
      sources: ["Demo/Sources/**"],
      resources: [
        "../CoachCoach/Assets.xcassets",
        "../CoachCoach/Resources/Assets.xcassets",
        "../CoachCoach/Resources/Fonts/**"
      ],
      dependencies: [
        .target(name: "FeatureOnboarding"),
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
