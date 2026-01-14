import ProjectDescription

let project = Project(
  name: "CoreModels",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "CoreModels",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.CoreModels",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: []
    )
  ]
)
