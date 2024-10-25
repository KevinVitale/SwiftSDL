// swift-tools-version: 6.0.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftSDL",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "SwiftSDL", targets: ["SwiftSDL"]),
    .executable(name: "sdl", targets: ["SwiftSDL-TestBench"])
  ],
  dependencies: [
    // .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
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
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .executableTarget(
      name: "SwiftSDL-TestBench",
      dependencies: [
        "SwiftSDL",
      ],
      path: "Samples/SwiftSDL-TestBench",
      resources: [
        .process("Resources/")
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-F", "-Xlinker", "/usr/local/lib",
          "-Xlinker", "-rpath", "-Xlinker", "/usr/local/lib",
        ], .when(platforms: [.macOS]))
      ]
    )
  ]
)
