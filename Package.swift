// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [
        .iOS(.v9), .macOS(.v10_10)
    ],
    products: [
        .library(name: "Workflow", targets: ["Workflow"]),
    ],
    targets: [
        .target(name: "Workflow", dependencies: []),
        .testTarget(name: "WorkflowTests", dependencies: ["Workflow"]),
    ]
)
