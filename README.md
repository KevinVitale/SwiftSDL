# SwiftSDL — Cross-Platform Targets with Swift & SDL3
 
 **SwiftSDL** is an open-source Swift library that provides a complete interface for working with the C-based [SDL (Simple DirectMedia Layer)](https://www.libsdl.org/) library. This wrapper allows developers to leverage SDL's cross-platform multimedia and game development capabilities in Swift applications across macOS, iOS, and Linux.
 
 ## <img src="https://www.libsdl.org/media/SDL_logo.png" height="20" max-width="90%" alt="SDL2" /> Simple DirectMedia Layer 3.0

 > _"Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware via OpenGL/Direct3D/Metal/Vulkan. It is used by video playback software, emulators, and popular games including Valve's award winning catalog and many Humble Bundle games."_ - [wiki.libsdl.org](https://wiki.libsdl.org/SDL3/FrontPage)

## 🏁 Getting Started

### 📋 Requirements

- [Swift 6.0.2](https://www.swift.org/install/macos/), or later; and,
- [SDL v3.1.6-preview](https://github.com/libsdl-org/SDL/releases/tag/preview-3.1.6), (required only for Linux).

### 🔧 Installation

```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MySDLGame",
    dependencies: [
      .package(url: "https://github.com/KevinVitale/SwiftSDL.git", from: "0.2.0-alpha.16"),),
    ],
    targets: [
        .executableTarget(
            name: "SwiftSDLTest",
            dependencies: [
              "SwiftSDL"
            ],
            resources: [
              .process("../Resources/BMP"),
            ]
        ),
    ]
)
```

### 💻 Platform-Specific Instructions

SwiftSDL doesn't work without SDL3. 

#### Apple

SwiftSDL works on **macOS**, **iOS**, and **tvOS** simply by adding it to your project's `Package.swift` file. A precompiled XCFramework containing the SDL3 library is provided. 

**You do not need to** build the XCFramework yourself. However, if you need to, the available [`Makefile`](https://github.com/KevinVitale/SwiftSDL/blob/main/Makefile) can be used:

```bash
# Clone KevinVitale/SwiftSDL
git clone https://github.com/KevinVitale/SwiftSDL
cd SwiftSDL

# Build XCFramework...grab some ☕️
make build-sdl-xcframework
```

#### Linux

#### Windows

## 🎁 Features

- Swift wrapper for the SDL library (vers. 3), exposing SDL's core functionality in an easy-to-use Swift API.
- Cross-platform support for macOS, Linux, and Windows, with simplified project management using the Swift Package Manager.
- iOS support using Objective-C to Swift bridging for SDL integration.
- A sample iOS application that demonstrates how to set up and use SDL3 with this library.

## Sample Code

Below is a basic example of how you can use SwiftSDL to initialize an SDL window in Swift:

| `Example.swift`  | Output  |
|---|---|
|<pre width="0" lang="swift">import SwiftSDL&#13;&#13;@main final class Example: Game {&#13;  @OptionGroup var options: GameOptions&#13;  func onReady(window: any Window) throws(SDL_Error) { }&#13;  func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {&#13;    let surface = try window.surface.get()&#13;    try surface.clear(color: .red)&#13;    try window.updateSurface()&#13;  }&#13;  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) { }&#13;  func onShutdown(window: (any Window)?) throws(SDL_Error) { }&#13;}</pre> | <img align="right" width="100%" alt="Screenshot 2024-10-26 at 2 30 44 PM" src="https://github.com/user-attachments/assets/8868d4b8-b714-4c87-90d0-ef82dd46b02f"> |

## Installation

### Swift Package Manager (SPM)

You can add **SwiftSDL** as a dependency in your project by adding the following to your `Package.swift` file:

```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftSDLTest",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/KevinVitale/SwiftSDL.git", from: "0.2.0-alpha.4"),
  ],
  targets: [
    .executableTarget(
      name: "SwiftSDLTest",
      dependencies: ["SwiftSDL"],

      // Optional: bundle resources!
      resources: [
        .process("../Resources/BMP")
      ],

      // Required: when using SPM YOU MUST
      // have libSDL3.{dylib|so|a} installed.
      linkerSettings: [.unsafeFlags(
        [
          "-Xlinker", "-F", "-Xlinker", "/usr/local/lib",
          "-Xlinker", "-rpath", "-Xlinker", "/usr/local/lib",
        ], .when(platforms: [.macOS])
      )]
    ),
  ]
)
```

### CMake (for non-SPM platforms)

```
// TODO
```

## Platform-Specific Instructions

### macOS
![](https://github.com/KevinVitale/SwiftSDLTest/blob/main/Resources/GitHub/osx-example.png)

### Linux
![](https://github.com/KevinVitale/SwiftSDLTest/blob/main/Resources/GitHub/linux-example.png)

### Windows

### iOS
![](https://github.com/KevinVitale/SwiftSDL/blob/main/Samples/SwiftSDL-Xcode/ios-example.gif)

## Contributions

**Fix Me:** Something like:

> _We welcome contributions from the community! Feel free to fork the repository, submit issues, or create pull requests. Be sure to follow the contribution guidelines and coding standards outlined in `CONTRIBUTING.md`._

## License

SwiftSDL is open-sourced under the MIT license. See the `LICENSE` file for details.

## Contact

**Fix Me:** Something like:

> _For questions or further assistance, please reach out via GitHub issues or contact the maintainers directly at `email@example.com`._

---

With **SwiftSDL**, you can effortlessly bring SDL's cross-platform multimedia power into the world of Swift!
