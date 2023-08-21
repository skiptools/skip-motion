// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "skip-motion",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
    .library(name: "SkipMotion", targets: ["SkipMotion"]),
    .library(name: "SkipMotionKt", targets: ["SkipMotionKt"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.0.0"),
        .package(url: "https://source.skip.tools/skip-unit.git", from: "0.0.0"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "0.0.0"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "0.0.0"),
    ],
    targets: [
    .target(name: "SkipMotion", plugins: [.plugin(name: "preflight", package: "skip")]),
    .target(name: "SkipMotionKt", dependencies: [
        "SkipMotion",
        .product(name: "SkipUnitKt", package: "skip-unit"),
        .product(name: "SkipLibKt", package: "skip-lib"),
        .product(name: "SkipFoundationKt", package: "skip-foundation"),
    ], resources: [.process("Skip")], plugins: [.plugin(name: "transpile", package: "skip")]),
    .testTarget(name: "SkipMotionTests", dependencies: [
        "SkipMotion"
    ], plugins: [.plugin(name: "preflight", package: "skip")]),
    .testTarget(name: "SkipMotionKtTests", dependencies: [
        "SkipMotionKt",
        .product(name: "SkipUnitKt", package: "skip-unit"),
        .product(name: "SkipLibKt", package: "skip-lib"),
        .product(name: "SkipFoundationKt", package: "skip-foundation"),
        .product(name: "SkipUnit", package: "skip-unit"),
    ], resources: [.process("Skip")], plugins: [.plugin(name: "transpile", package: "skip")]),
    ]
)