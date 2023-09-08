// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "skip-motion",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
    .library(name: "SkipMotion", targets: ["SkipMotion"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.6.57"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "0.1.16"),
    ],
    targets: [
    .target(name: "SkipMotion", dependencies: [.product(name: "SkipFoundation", package: "skip-foundation", condition: .when(platforms: [.macOS]))], plugins: [.plugin(name: "skipstone", package: "skip")]),
    .testTarget(name: "SkipMotionTests", dependencies: [
        "SkipMotion",
        .product(name: "SkipTest", package: "skip", condition: .when(platforms: [.macOS]))
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
