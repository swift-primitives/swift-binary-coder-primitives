// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-binary-coder-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Binary Coder Primitives",
            targets: ["Binary Coder Primitives"]
        ),
        .library(
            name: "Binary Integer Coder Primitives",
            targets: ["Binary Integer Coder Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-binary-parser-primitives"),
        .package(path: "../swift-input-primitives"),
        .package(path: "../swift-witness-primitives"),
        .package(path: "../swift-coder-primitives"),
    ],
    targets: [
        .target(
            name: "Binary Coder Primitives",
            dependencies: [
                .product(name: "Binary Input Primitives", package: "swift-binary-parser-primitives"),
                .product(name: "Binary Machine Primitives", package: "swift-binary-parser-primitives"),
                .product(name: "Witness Primitives", package: "swift-witness-primitives"),
                .product(name: "Coder Primitives", package: "swift-coder-primitives"),
            ]
        ),
        .target(
            name: "Binary Integer Coder Primitives",
            dependencies: [
                "Binary Coder Primitives",
                .product(name: "Input Primitives", package: "swift-input-primitives"),
            ]
        ),
        .testTarget(
            name: "Binary Coder Primitives Tests",
            dependencies: [
                "Binary Coder Primitives",
                "Binary Integer Coder Primitives",
                .product(name: "Binary Parser Primitives Test Support", package: "swift-binary-parser-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
