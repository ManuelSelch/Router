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
        .package(url: "https://github.com/davdroman/swiftui-navigation-transitions.git", .upToNextMajor(from: "0.13.4")),
        .package(url: "https://github.com/exyte/PopupView.git", .upToNextMajor(from: "3.0.5"))
    ],
    targets: [
        .target(
            name: "Router",
            dependencies: [
                .product(name: "PopupView", package: "PopupView"),
                .product(name: "NavigationTransitions", package: "swiftui-navigation-transitions")
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
