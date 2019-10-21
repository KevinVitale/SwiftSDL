# SwiftSDL

<img width=240 src="example.gif"/>

## Testing It Out
Use `Homebrew` to install the `SDL2` dependency, and then run `DemoSDL2`:

```bash
# Install Deps
$ brew install sdl2 sdl2_image

# Pull Repo
$ git clone git@github.com:KevinVitale/SwiftSDL.git

# Run DemoSDL2
$ cd SwiftSDL2
$ make && make run
```

## Quick Intro

The ♥️ of making `SwiftSDL2` simple to use is `SDLPointer<SDL_Type>`.  

Typealiases keep the interface easy to read (`Window`, `Renderer`, `Texture`, etc...), 
but you'll frequently use wrappers around `OpaquePointer`, which take methods as input
to bridge from `SDL2` to _Swift_.

For example, to read the `width` and `height` of a renderer's logical size:
```swift
// Get logical renderer size ---------------------------------------------------
var width: Int32 = .zero, height: Int32 = .zero
let rendererSize = try renderer?.result(of: SDL_GetRendererOutputSize, &width, &height)
print("\(width) x \(height)")
```

### Full Example
This example is an excerpt from `CreateWindowDemo`:

```swift
try SDL.Init(subSystems: .video)

// Print available renderers ---------------------------------------------------
Renderer.availableRenderers().forEach {
print($0)
}
SDL.Hint.set("software", for: .renderDriver)

// Create window ---------------------------------------------------------------
let window = try Window(width: 640, height: 480, flags: .allowHighDPI)

// Create renderer -------------------------------------------------------------
let renderer = window
    .pass(to: SDL_CreateRenderer, -1, 0)
    .map(Renderer.init)

// Set background color --------------------------------------------------------
renderer?.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 255) // Set bg-color

// Print renderer info ---------------------------------------------------------
if let renderer = renderer {
    print(try renderer.info())
}

// Get logical renderer size ---------------------------------------------------
var width: Int32 = .zero, height: Int32 = .zero
let rendererSize = renderer?.pass(to: SDL_GetRendererOutputSize, &width, &height)
print("\(width) x \(height)")

/* OMITTED: Game-Loop & Shutdown Cleanup */
```

