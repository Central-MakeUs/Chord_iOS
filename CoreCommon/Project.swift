import ProjectDescription

let project = Project(
  name: "CoreCommon",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "CoreCommon",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.CoreCommon",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: []
    )
  ]
)
