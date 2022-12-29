// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IRSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "IRSDK",
            targets: ["IRSDK"]),
    ],
    targets: [
        .binaryTarget(name: "IRSDK", path: "IRSDK.xcframework")
    ]
)
