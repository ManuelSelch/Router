// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Router",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17)],
    products: [
        .library(name: "Router", targets: ["Router"]),
        .library(name: "RouterDemo", targets: ["RouterDemo"])
    ],
    targets: [
        .target(name: "Router"),
        .target(name: "RouterDemo", dependencies: ["Router"], path: "Sources/Demo"),
        .testTarget(name: "RouterTests", dependencies: ["Router"])
    ]
)
