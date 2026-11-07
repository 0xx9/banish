// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cliner",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Cliner", targets: ["Cliner"])
    ],
    targets: [
        .target(name: "ClinerCore"),
        .executableTarget(
            name: "Cliner",
            dependencies: ["ClinerCore"]
        ),
        .testTarget(
            name: "ClinerCoreTests",
            dependencies: ["ClinerCore"]
        )
    ]
)
