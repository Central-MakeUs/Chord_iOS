import ProjectDescription

let project = Project(
  name: "DesignSystem",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "DesignSystem",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.DesignSystem",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: [
        "../CoachCoach/Resources/Fonts/**",
        "../CoachCoach/Assets.xcassets",
        "../CoachCoach/Resources/Assets.xcassets"
      ],
      dependencies: []
    )
  ]
)
