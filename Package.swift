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
        .package(url: "https://source.skip.tools/skip.git", from: "1.6.2"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.33.1"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.2"),
    ],
    targets: [
    .target(name: "SkipMotion", dependencies: [
        .product(name: "SkipUI", package: "skip-ui"),
        .product(name: "Lottie", package: "lottie-ios", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .macCatalyst]))
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    .testTarget(name: "SkipMotionTests", dependencies: [
        "SkipMotion",
        .product(name: "SkipTest", package: "skip")
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

if Context.environment["SKIP_BRIDGE"] ?? "0" != "0" {
    package.dependencies += [.package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0")]
    package.targets.forEach({ target in
        target.dependencies += [.product(name: "SkipFuseUI", package: "skip-fuse-ui")]
    })
    // all library types must be dynamic to support bridging
    package.products = package.products.map({ product in
        guard let libraryProduct = product as? Product.Library else { return product }
        return .library(name: libraryProduct.name, type: .dynamic, targets: libraryProduct.targets)
    })
}
