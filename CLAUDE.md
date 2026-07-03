# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftSDL is a Swift wrapper library for SDL3 (Simple DirectMedia Layer) targeting macOS, iOS, tvOS, and Linux. Swift 6.0+, typed throws throughout (`throws(SDL_Error)`).

## Commands

```bash
swift build                        # build library + test bench
swift run sdl <group> <command>    # run the test bench executable ("sdl")

# Examples:
swift run sdl test sprite          # test group: audio-info, camera, controller,
                                   #   geometry, mouse-grid, gpu-examples, sprite
swift run sdl games flappy-bird    # games group: flappy-bird, sandbox, stinky-duck
swift run sdl test sprite --help   # list GameOptions runtime flags (window size, vsync, etc.)
```

`swift test` runs the `SwiftSDLTests` target (Swift Testing). The suite is fully headless: SDL initializes once with the "dummy" video driver, and drawing is verified pixel-by-pixel through a software renderer over a plain surface (fixtures in `Tests/SwiftSDLTests/SDLTestSupport.swift`). Conventions:

- SDL is process-global state — every suite that touches SDL at runtime nests under the `.serialized` `SDLRuntimeTests` umbrella. Pure-math tests (e.g. geometry) stay outside and run in parallel.
- Crash-prone behavior runs as Swift Testing **exit tests** (`#expect(processExitsWith:)`), so a segfault or `fatalError` reads as a failed expectation instead of killing the run.
- Some tests are **deliberately red**: they encode known-but-unfixed bugs TDD-style. Each such test's doc comment says so and describes the fix it awaits — never make a red test pass by weakening its expectations. A fully green suite means those bugs are fixed.
- One suite is compile-time-gated behind `swift test -Xswiftc -DSWIFTSDL_TASK2_FIXED` because the API it exercises currently doesn't compile.

The `SwiftSDL-TestBench` executable remains the end-to-end verification tool — run the relevant bench command and observe the window it opens.

Rebuilding the bundled SDL3.xcframework (rarely needed; requires cmake + ninja):

```bash
make build-sdl-xcframework    # clones SDL at the ref pinned by SDL_REF in the Makefile
```

To bump the vendored SDL version: update `SDL_REF` in the Makefile, rebuild the xcframework, and replace `Dependencies/SDL3.xcframework`.

## Architecture

### Target layering (Package.swift)

SDL3 reaches Swift through platform-conditional targets:

- **`SDL3`** — binary target: prebuilt `Dependencies/SDL3.xcframework` (Apple platforms).
- **`CSDL`** (`Dependencies/CSDL`) — C shim exposing the xcframework headers to Swift (Apple).
- **`CSDL3`** (`Dependencies/CSDL3`) — system-library target using `pkg-config sdl3` (Linux; SDL3 must be built/installed from source there). Windows is unsupported.
- **`SwiftSDL`** — the library; depends on `CSDL` on Apple platforms and `CSDL3` on Linux/Windows. `_Exported.swift` re-exports the C SDL module and ArgumentParser, so client code only ever writes `import SwiftSDL` and gets raw `SDL_*` functions plus `@Option`/`@Flag` etc. for free.
- **`SwiftSDL-TestBench`** — the `sdl` executable (`Samples/SwiftSDL-TestBench`), with bundled resources.

### Core wrapper pattern (Sources/SwiftSDL/ObjectProtocol.swift)

Everything SDL-object-like is an `SDLObject<Pointer>` — a RAII class holding a raw SDL pointer and a `destroy` closure run on `deinit` (e.g. `SDL_DestroyRenderer`). Public API types are protocol views over it:

```swift
public protocol Renderer: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }
extension SDLObject<OpaquePointer>: Renderer { }
```

APIs return/accept existentials (`any Window`, `some Renderer`). New wrapper types (Window, Renderer, Surface, Texture, GPUDevice, …) follow this same protocol + `SDLObject` extension recipe, one file per SDL concept.

`SDLObjectProtocol` provides `callAsFunction` overloads (parameter packs) so wrapped objects invoke raw SDL C functions directly, converting SDL's `false`/`NULL` failures into thrown `SDL_Error`:

```swift
try window(SDL_MinimizeWindow)                        // throws on false
try renderer(SDL_SetRenderDrawColor, 0, 0, 0, 0xFF)   // extra args forwarded
window.resultOf(SDL_GetWindowTitle)                   // Result-returning variant
```

`SDL_Error` (Error.swift) has no payload for the common case — `.error` reads `SDL_GetError()` lazily in its `debugDescription`. `SDL_BufferPointer(_:)` converts SDL's count-out-pointer allocation style into Swift arrays.

Fluent chaining is the house style for rendering: methods return `self` as `@discardableResult`, e.g. `try renderer.clear(color: .gray).fill(rects: ..., color: .white).present()`.

### Game protocol (Sources/SwiftSDL/Game.swift + App.swift)

`Game` is the application framework: a class conforming to `Game` with `@main` is a complete app. It maps the lifecycle — `onInit` → `onReady` → `onUpdate`/`onEvent` loop → `onShutdown` → `onQuit` — onto SDL3's main callbacks (`SDL_EnterAppMainCallbacks` inside `Game.run()`). The `App` enum holds the global state (game, window, frame timing/`deltaTime`, failure bookkeeping).

`Game` extends `ParsableCommand`, so every game is also a CLI command: `GameOptions` (via `@OptionGroup`) supplies the standard `--window-*` / vsync / logical-size flags, applied to the window after `onReady` in `Window.sync(options:)`. Because `ParsableCommand` is `Decodable`, game classes must declare `CodingKeys` listing only their parsed properties (`options`, plus any `@Argument`/`@Flag`).

Game-controller hot-plugging is handled centrally in the event callback (diffs `SDL_GetJoysticks` on add/remove events) and surfaces through the optional `did(connect:)` / `will(remove:)` hooks.

### Test bench structure (Samples/SwiftSDL-TestBench)

`Sources/SDL.swift` defines the root command with grouped subcommands `test` and `games`; each subcommand is a `Game` conformance in `Sources/Tests/` or `Sources/Games/` (the tests reimplement upstream SDL's C test programs). `Sources/Utils/` has a small scene-graph and sprite-animation layer used by the games. Resources (BMPs, gamepad art, precompiled shaders in DXIL/MSL/SPIR-V) are `.process`-ed into the bundle and loaded via the `Load(bitmap:)` / `Load(shader:...)` helpers, which search resource bundles by name.

### Repo notes

- `Documentation/README-error.md` documents the error-handling conventions in depth.
- Git submodules: `Dependencies/SDL` (upstream SDL source) and `Samples/SwiftSDLTest`. The `Dependencies/SDL3/` clone directory created by `make clone-sdl` is gitignored.
- `Samples/SwiftSDL-Xcode` and `Samples/SwiftSDL-macUI` are standalone Xcode sample projects, not part of the SwiftPM build.
