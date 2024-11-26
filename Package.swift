// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSLogViewer",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "LSLogViewer",
            targets: ["LSLogViewer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LSLogViewer",
            dependencies: [],
            path: "LSLogViewer",
            publicHeadersPath: ""),
    ]
)
