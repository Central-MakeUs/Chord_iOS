import ProjectDescription

let project = Project(
  name: "DataLayer",
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
