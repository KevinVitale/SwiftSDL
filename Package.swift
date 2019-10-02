// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftSDL",
    products: [
      .library( name: "SwiftSDL2", targets: ["SwiftSDL2"] ),
      .executable( name: "DemoSDL2", targets: ["DemoSDL2"]),
    ],
    targets: [
      .target( name: "DemoSDL2", dependencies: ["SwiftSDL2"]), 
      .target( name: "SwiftSDL2", dependencies: ["CSDL2"]),
      .systemLibrary( name: "CSDL2", pkgConfig: "sdl2"
        , providers: [ .brew(["sdl2"]), .apt(["libsdl2-dev"]) ]
      ),
      //.testTarget( name: "SDLTests", dependencies: ["SDL"]),
    ],
    swiftLanguageVersions: [.v5]
)
