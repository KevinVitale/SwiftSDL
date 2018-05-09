// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftSDL",
    products: [
        .library(
            name: "SwiftSDL",
            targets: ["SwiftSDL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KevinVitale/Clibsdl2.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftSDL",
            dependencies: ["Clibsdl2"])
    ]
)
