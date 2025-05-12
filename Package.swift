// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Router",
    platforms: [
        .iOS(.v14),
        .macOS(.v14),
        .macCatalyst(.v16)
    ],
    products: [
        .library(name: "Router", targets: ["Router", "RouterDemo"]),
       
    ],
    dependencies: [
        .package(url: "https://github.com/davdroman/swiftui-navigation-transitions.git", .upToNextMajor(from: "0.15.1")),
        .package(url: "https://github.com/huri000/SwiftEntryKit", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: [
                .product(name: "SwiftUINavigationTransitions", package: "swiftui-navigation-transitions"),
                .product(name: "SwiftEntryKit", package: "SwiftEntryKit")
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
