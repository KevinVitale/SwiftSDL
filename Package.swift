// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftSDL2",
    products: [
        .library(
            name: "SwiftSDL2",
            targets: ["SwiftSDL2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KevinVitale/Clibsdl2.git", .revision("master")),
    ],
    targets: [
        .target(
            name: "SwiftSDL2",
            dependencies: ["Clibsdl2"])
    ]
)
