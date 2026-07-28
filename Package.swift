// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-seeded-random",
  products: [
    .library(name: "SeededRandom", targets: ["SeededRandom"]),
  ],
  targets: [
    .target(name: "SeededRandom"),
    .testTarget(name: "SeededRandomTests", dependencies: ["SeededRandom"]),
  ])
