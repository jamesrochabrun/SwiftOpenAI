// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOpenAI",
    platforms: [
         .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftOpenAI",
            targets: ["SwiftOpenAI"]),
    ],
    dependencies: [
      .package(url: "https://github.com/jamesrochabrun/SwiftOpenAI.git", branch: "jroch-swift-open-ai-1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftOpenAI"),
        .testTarget(
            name: "SwiftOpenAITests",
            dependencies: ["SwiftOpenAI"]),
    ]
)
