// swift-tools-version: 5.9
import PackageDescription
import Foundation

let package = Package(
    name: "skip-motion",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipMotion", targets: ["SkipMotion"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.2.18"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.17.2"),
        .package(url: "https://source.skip.tools/skip-bridge.git", "0.0.0"..<"2.0.0"), // FIXME: needed for #if SKIP, but shouldn't be needed for bridgeless mode
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.1"),
    ],
    targets: [
    .target(name: "SkipMotion", dependencies: [
        .product(name: "SkipUI", package: "skip-ui"),
        .product(name: "SkipBridge", package: "skip-bridge"),
        .product(name: "Lottie", package: "lottie-ios", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .macCatalyst]))
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    .testTarget(name: "SkipMotionTests", dependencies: [
        "SkipMotion",
        .product(name: "SkipTest", package: "skip")
    ], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

if ProcessInfo.processInfo.environment["SKIP_BRIDGE"] ?? "0" != "0" {
    package.dependencies += [.package(url: "https://source.skip.tools/skip-fuse-ui.git", "0.0.0"..<"2.0.0")]
    package.targets.forEach({ target in
        target.dependencies += [.product(name: "SkipFuseUI", package: "skip-fuse-ui")]
        // need to manually pare out Lottie, even though this should be excluded by the package conditionals
        // failure to do so raises the odd error:
        // multiple packages ('lottie' (at 'PROJECT/Build/Intermediates.noindex/BuildToolPluginIntermediates/skipapp-notes.output/SkipNotes/skipstone/SkipNotes/src/main/swift/Packages/Lottie'), 'lottie-ios' (from 'https://github.com/airbnb/lottie-ios.git')) declare products with a conflicting name: 'Lottie’; product names need to be unique across the package graph
        target.dependencies = target.dependencies.filter({ dep in
            switch dep {
            case .productItem(name: let name, package: _, moduleAliases: _, condition: _):
                return name != "Lottie"
            default:
                return true
            }
        })
    })
    // all library types must be dynamic to support bridging
    package.products = package.products.map({ product in
        guard let libraryProduct = product as? Product.Library else { return product }
        return .library(name: libraryProduct.name, type: .dynamic, targets: libraryProduct.targets)
    })
}
