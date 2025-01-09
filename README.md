# SwiftSDL — Cross-Platform Targets with Swift & SDL3

[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)](LICENSE.md)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKevinVitales%2FSwiftSDL%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/KevinVitale/SwiftSDL)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKevinVitale%2FSwiftSDL%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/KevinVitale/SwiftSDL)
 
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
    platforms: [
      .macOS(.v13)
    ],
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

## 👀 Overview

Like Swift itself, SwiftSDL makes SDL3 approachable for newcomers and powerful for experts.

### 👾 Introduction

A complete SwiftSDL game consists of the following 22-lines of code:

```swift
import SwiftSDL

@main
final class MyGame: Game {
    private enum CodingKeys: String, CodingKey {
        case options
    }

    @OptionGroup
    var options: GameOptions

    func onReady(window: any Window) throws(SDL_Error) {
      /* create a renderer, or acquire a gpu device. */
      /* load assets or resources. */
    }

    func onUpdate(window: any Window) throws(SDL_Error) {
      /* handle game logic and render frames */
    }

    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      /* respond to events */
    }

    func onShutdown(window: (any Window)?) throws(SDL_Error) {
      /* release objects and unload resources */
    }
}
```

The class, `MyGame`, conforms to the `Game` protocol. A window is created automatically using reasonable defaults, although, it's possible to override the window's creation manually.

Underneath the hood, the `Game` protocol has implemented [SDL3's new main callbacks](https://wiki.libsdl.org/SDL3/README/main-functions#how-to-use-main-callbacks-in-sdl3).

`GameOptions` are runtime arguments which alter the behavior or your application, such as your window's appearance.

### 🧩 Tutorial

Let's create an app using SwiftSDL from start-to-finish.

#### Step 1: Create the project
Using Swift's command-line utility, we'll create the project in an empty directory

```bash
# Create an empty directory for our project
mkdir MyGame
cd MyGame

# Create the executable package
swift package init --type executable
```
 
#### Step 2: Add SwiftSDL

Update the `Package.swift` file to include SwiftSDL as a dependency:

> **Note:** you may need adjust `platforms` to use `.macOS(.v13)`.

```swift
// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyGame",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
      .package(url: "https://github.com/KevinVitale/SwiftSDL.git", from: "0.2.0-alpha.17")
    ],
    targets: [
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "MyGame",
            dependencies: [
               "SwiftSDL"
            ]
        ),
    ]
)
```

#### Step 3: Create the game

Rename `main.swift` to `MyGame.swift`:

```bash
mv Sources/main.swift Sources/MyGame.swift
```

Then replace `MyGame.swift` with the following code:

```swift
import SwiftSDL

@main
final class MyGame: Game {
    private enum CodingKeys: String, CodingKey {
      case options, message
    }

    @OptionGroup
    var options: GameOptions

    @Argument
    var message: String = "Hello, SwiftSDL!"

    private var renderer: (any Renderer)! = nil

    func onReady(window: any Window) throws(SDL_Error) {
      renderer = try window.createRenderer()
    }

    func onUpdate(window: any Window) throws(SDL_Error) {
      try renderer
        .clear(color: .gray)
        .debug(text: message, position: [12, 12], scale: [2, 2])
        .fill(rects: [24, 48, 128, 128], color: .white)
        .fill(rects: [36, 60, 104, 104], color: .green)
        .present()
    }

    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    }

    func onShutdown(window: (any Window)?) throws(SDL_Error) {
      renderer = nil
    }
}
```

Then start the game:

```bash
swift run
```

> **Note:** You should see a window with a gray background, a message saying _"Hello, SwiftSDL!"_, and two squares: one large white one, and a smaller green one.

Your game has several options built-in. To see them all, use `--help`:

```bash
swift run MyGame --help
USAGE: my-game [<options>] [<message>]

ARGUMENTS:
  <message>               (default: Hello, SwiftSDL!)

OPTIONS:
  --hide-cursor           Hide the system's cursor
  --auto-scale-content    Stretch the content to fill the window
  --logical-size <logical-size>
                          Forces the rendered content to be a certain logical size (WxH)
  --logical-presentation <logical-presentation>
                          Forces the rendered content to be a certain logical order; overrides '--auto-scale-content' (values: disabled,
                          stretch, letterbox, overscan, integer-scale; default: disabled)
  --vsync-rate <vsync-rate>
                          Set vertical synchronization rate (values: adaptive, disabled, interger value; default: disabled)
  --window-always-on-top  Window is always kept on top
  --window-fullscreen     Window is set to fullscreen
  --window-transparent    Window is uses a transparent buffer
  --window-maximized      Create a maximized window; requires '--window-resizable'
  --window-minimized      Create a minimized window
  --window-max-size <window-max-size>
                          Specify the maximum window's size (WxH)
  --window-min-size <window-min-size>
                          Specify the minimum window's size (WxH)
  --window-mouse-focus    Force the window to have mouse focus
  --window-no-frame       Create a borderless window
  --window-resizable      Enable window resizability
  --window-position <window-position>
                          Specify the window's position (XxY)
  --window-size <window-size>
                          Specify the window's size (WxH)
  --window-title <window-title>
                          Specify the window's title
  -h, --help              Show help information.
```

#### Step 4: Sample Apps

SwiftSDL includes several samples to help you get started.

##### Test Bench

These are reimplementations of a variety of [SDL3's tests](https://github.com/libsdl-org/SDL/tree/main/test) using SwiftSDL:

| Build Command | Image Preview |
|-|-|
| `swift run sdl test audio-info` | <img width="240" alt="test-controller" src="https://github.com/user-attachments/assets/cd9574ca-92a2-4a4c-8bad-eeee9593bbb6"/> |
| `swift run sdl test controller` | <img width="480" alt="test-controller" src="https://github.com/user-attachments/assets/c67d6e8b-3a25-48d6-b195-b501ae536f4f"/> |
| `swift run sdl test camera`     | <img width="480" alt="test-camera" src="https://github.com/user-attachments/assets/e817a454-970b-4b63-ba74-3541b951f532"/> |
| `swift run sdl test geometry`   | <img width="480" alt="test-geometry" src="https://github.com/user-attachments/assets/13a9af58-6668-48a0-9cca-70b76472a569"/> |
| `swift run sdl test mouse-grid` | <img width="480" alt="mouse-grid" src="https://github.com/user-attachments/assets/28902a4c-6fb1-4c08-aa9c-d1047831fb41"/> |
| `swift run sdl test sprite`     | <img width="480" alt="test-sprite" src="https://github.com/user-attachments/assets/9e1b8c5e-d4bd-471c-9d61-a3337442981f"/> |
| `swift run sdl test gpu-examples` | <img width="480" alt="test-sprite" src="https://github.com/user-attachments/assets/082778b6-3f9e-4612-b187-930af3e7d74f"/> |

##### Games

| Build Command | Image Preview |
|-|-|
| `swift run sdl games flappy-bird` | <img width="480" alt="game-flappy-bird" src="https://github.com/user-attachments/assets/2817f22c-8557-4871-bfb8-b2bf496ffb77"> |
| `swift run sdl games stinky-duck` | <img width="480" alt="game-flappy-bird" src="https://github.com/user-attachments/assets/afad73dd-bbd7-48f4-b6fd-144d61172968"> |

##### Xcode Project: macOS, iOS, tvOS

Explore: [Samples/SwiftSDL-Xcode](https://github.com/KevinVitale/SwiftSDL/tree/main/Samples/SwiftSDL-Xcode)

## 💻 Platform-Specific Instructions

SwiftSDL doesn't work without SDL3. Refer to the following sections to ensure SwiftSDL compiles properly.

### Apple

SwiftSDL works on **macOS**, **iOS**, and **tvOS** simply by adding it to your project's `Package.swift` file. A precompiled XCFramework containing the SDL3 library is provided. 

##### Building the XCFramework with the Makefile

**You do not need to** build the XCFramework yourself. However, if you need to, the available [`Makefile`](https://github.com/KevinVitale/SwiftSDL/blob/main/Makefile) can be used:

```bash
# Clone KevinVitale/SwiftSDL
git clone https://github.com/KevinVitale/SwiftSDL
cd SwiftSDL

# Build XCFramework...grab some ☕️
make build-sdl-xcframework
```
![]()
<img src="https://github.com/KevinVitale/SwiftSDLTest/blob/main/Resources/GitHub/osx-example.png" width="320" alt="macOS-example" /> 
<img src="https://github.com/KevinVitale/SwiftSDL/blob/main/Samples/SwiftSDL-Xcode/ios-example.gif" width="320" alt="iOS-example" />

### Linux

You must build and install SDL3 from source. Thankfully, it's easy and should take only a few minutes:

 1. [Install whichever dependencies your need](https://wiki.libsdl.org/SDL3/README/linux) for your game; and,
 2. [Build and install from source](https://wiki.libsdl.org/SDL3/Installation#linuxunix).

<img src="https://github.com/KevinVitale/SwiftSDLTest/blob/main/Resources/GitHub/linux-example.png" height="480" max-width="50%" alt="linux-example" />

### Windows

Support for Windows is currently unavailable.

## 🎨 Authors

 - [Kevin Vitale](https://github.com/KevinVitale)

## 📁 License

SwiftSDL is open-sourced under the MIT license. See the `LICENSE` file for details.
