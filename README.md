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

## Overview

The ♥️ of making `SwiftSDL2` simple to use is `SDLPointer<SDLType>`.  

A common reaction for wrapper library authors is to expose APIs which explicitly call into every potential underlying API. [This has the benefit of feeling _"native"_](https://github.com/PureSwift/SDL/blob/master/Sources/SDL/Window.swift); however, it is ultimately very slow, error-prone, and scales extremely poorly.

To solve this, `SDLPointer<SDLType>` creates a genericized interface to wrap the `OpaquePointer` instances returned by the `SDL2` when bridged to _Swift_. Being a `SDLType` adopter means describing the pointer's intent as an object (`SDLWindow`, `SDLRenderer`, `SDLTexture`, etc...), and implementing a function which invokes the corresponding `SDL2` API associated with freeing its memory.

As an example, here is how `SDLWindow` adopts `SDLType`:

```swift
public struct SDLWindow: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyWindow(pointer)
    }
}
```

Lastly, typealiases for `SDLPointer<SDLType>` make interfaces more readable (e.g., `Window`, `Renderer`, `Texture`, etc...).  

### Methodology of `SDLPointer<SDLType>`
`SDLPointer<SDLType>` has just two functions:
  - `result(of:)` is used for `SDL2` functions which return errors; and,
  - `pass(to:)` is used for `SDL2` functions that don't error-out.
  
Because these are member functions, you're able to call them on `Optional` instances of `SDLPointer<SDLType>`, foregoing the need to constantly be checking for `nil`.
  
#### `result(of:)`
This function does a great job of squashing multiple concerns into a single function call.  

```swift
let renderer: Renderer? = /* provided elsewhere */
renderer?.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 255) // 1. Set bg-color
renderer?.result(of: SDL_RendererClear)                          // 2. clear render target
renderer?.pass(to: SDL_RendererPresent)                          // 3. send rendering calls to GPU
```

You have total freedom for deciding when it is necessary for your application to handle potential errors, and in the case of `result(of:)`, you may decide to ignore the `Result` being returned, or call `try...get()` if you're interested in handling potential errors.

#### `pass(to:)`
Let's say you wanted to use `IMG_LoadTexture` to create a new texture object. Here is the interface for this function:
```swift
func IMG_LoadTexture(_ renderer: OpaquePointer!, _ file: UnsafePointer<Int8>!) -> OpaquePointer!
```

We need to pass an `OpaquePointer!` as the first argument, and a file path to the second argument. Let's look at how `pass(to:)` is used to help us with this, by taking an array of texture file names and mapping them into a `Texture` instance:

```swift
let renderer: Renderer? = /* provided elsewhere */
let resourceURL = Bundle.main.resourceURL!
let textures = ["texture_1.png", "texture_2.png", "texture_3.png"]       // 1. Names of files
            .compactMap { resourceURL.appendingPathComponent($0) }       // 2. Created as full file paths
            .compactMap { renderer?.pass(to: IMG_LoadTexture, $0.path) } // 3. Pass 'OpaquePointer' to IMG_LoadTexture
            .map(Texture.init)                                           // 4. Get returned 'OpaquePointer', send to '.init'
```

In just a few lines of code, we've called `IMG_LoadTexture` using a potentially `nil` `Renderer` object; and created new `Texture` instances for just those file names which returned valid pointers from `IMG_LoadTexture`.   

### Why this matters?

None of examples involved an explicit implementations within `SwiftSDL2` in order for them to work. Nor do they require `SwiftSDL2` to coordinate API calls involving the bespoke types it introduces (`Renderer`, `Texture`, etc.). Finally, role `Renderer` takes when creating `Texture` remains solely within the underlying `SDL2` (and `SDL2_image`) libraries which are already very welld defined.

## More Examples
Let's see more of `SDLPointer<SDLType>` in action! 🎉

### Get the renderer's logical size

For example, to read the `width` and `height` of a renderer's logical size:
```swift
// Get logical renderer size ---------------------------------------------------
do {
    var width: Int32 = .zero, height: Int32 = .zero
    try renderer?.result(of: SDL_GetRendererOutputSize, &width, &height).get()
    print("\(width) x \(height)")
} catch {
    print(error)
}
```

### Create Window Example
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

## License
```
Copyright (c) 2019 Kevin J. Vitale

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
