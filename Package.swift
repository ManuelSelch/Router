// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Router",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .macCatalyst(.v16)
    ],
    products: [
        .library(name: "Router", targets: ["Router", "RouterDemo"]),
       
    ],
    dependencies: [
        .package(url: "https://github.com/manuelselch/Redux", .upToNextMajor(from: "1.2.14")),
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: [
                .product(name: "Redux", package: "Redux")
            ]
        ),
        .target(
            name: "RouterDemo",
            dependencies: ["Router"],
            path: "Sources/Demo"
        ),
        .testTarget(
            name: "RouterTests",
            dependencies: ["Router"]
        ),
    ]
)
