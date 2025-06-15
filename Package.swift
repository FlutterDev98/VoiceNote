// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NoteTakingApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NoteTakingApp",
            targets: ["NoteTakingApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/shu223/Pulsator.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "NoteTakingApp",
            dependencies: ["Pulsator"]),
        .testTarget(
            name: "NoteTakingAppTests",
            dependencies: ["NoteTakingApp"]),
    ]
) 