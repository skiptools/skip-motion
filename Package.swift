// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "skip-motion",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
    .library(name: "SkipMotion", targets: ["SkipMotion"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.8.0"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "0.5.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.3"),
    ],
    targets: [
    .target(name: "SkipMotion", dependencies: [.product(name: "SkipUI", package: "skip-ui"), .product(name: "Lottie", package: "lottie-ios")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    .testTarget(name: "SkipMotionTests", dependencies: [
        "SkipMotion",
        .product(name: "SkipTest", package: "skip")
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
