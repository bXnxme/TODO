// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TODO",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TODOCore",
            targets: ["TODOCore"]
        )
    ],
    targets: [
        .target(
            name: "TODOCore",
            path: "Sources/TODOCore"
        ),
        .testTarget(
            name: "TODOCoreTests",
            dependencies: ["TODOCore"],
            path: "Tests/TODOCoreTests"
        )
    ]
)

