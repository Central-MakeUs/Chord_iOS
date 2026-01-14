import ProjectDescription

let project = Project(
  name: "DataLayer",
  organizationName: "CoachCoach",
  settings: .settings(
    base: [
      "SWIFT_VERSION": "5.9"
    ]
  ),
  targets: [
    .target(
      name: "DataLayer",
      destinations: [.iPhone],
      product: .framework,
      bundleId: "com.seungwan.CoachCoach.DataLayer",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .external(name: "ComposableArchitecture"),
        .project(target: "CoreModels", path: "../CoreModels")
      ]
    )
  ]
)
