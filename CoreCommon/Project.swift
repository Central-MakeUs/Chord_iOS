import ProjectDescription

let project = Project(
  name: "CoreCommon",
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
