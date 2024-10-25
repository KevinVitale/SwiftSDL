// swift-tools-version: 6.0.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftSDL",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "SwiftSDL", targets: ["SwiftSDL"])
  ],
  dependencies: [
    // .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
  ],
  targets: [
    .binaryTarget(name: "SDL3", path: "Dependencies/SDL3.xcframework"),
    .systemLibrary(
      name: "CSDL3",
      path: "Dependencies/CSDL3",
      pkgConfig: "sdl3",
      providers: [
        .apt(["libsdl3-dev"])
      ]),
    /*
    .systemLibrary(
      name: "CSDL3_Image",
      path: "Dependencies/CSDL3_Image",
      pkgConfig: "sdl3-image",
      providers: [
        .apt(["libsdl3_image-dev"])
      ]),
    .systemLibrary(
      name: "CSDL3_TTF",
      path: "Dependencies/CSDL3_TTF",
      pkgConfig: "sdl3-ttf",
      providers: [
        .apt(["libsdl3_ttf-dev"])
      ]),
     */
    .target(
      name: "SwiftSDL",
      dependencies: [
        .target(name: "CSDL3"),
        // .target(name: "CSDL3_Image"),
        // .target(name: "CSDL3_TTF"),
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .testTarget(
      name: "SwiftSDLTests",
      dependencies: ["SwiftSDL"],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-rpath", "-Xlinker", "/usr/local/lib"
        ])
      ]
    )
  ]
)
