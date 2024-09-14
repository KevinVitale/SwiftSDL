// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftSDL",
  platforms: [
    .macOS(.v14),
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "SwiftSDL",
      type: .dynamic,
      targets: ["SwiftSDL"]
    )
  ],
  dependencies: [
    // .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
  ],
  targets: [
    .systemLibrary(
      name: "CSDL3",
      path: "Dependencies/CSDL3",
      pkgConfig: "sdl3",
      providers: [
        .apt(["libsdl3-dev"])
      ]),
    .target(
      name: "SwiftSDL",
      dependencies: [
        .target(name: "CSDL3"),
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "SwiftSDLTests",
      dependencies: ["SwiftSDL"],
      linkerSettings: [
        .unsafeFlags(["-Xlinker", "-rpath"], .when(platforms: [.macOS, .linux, .windows])),
        .unsafeFlags(["-Xlinker", "/usr/local/lib"], .when(platforms: [.macOS, .linux, .windows]))
      ]
    )
  ]
)
