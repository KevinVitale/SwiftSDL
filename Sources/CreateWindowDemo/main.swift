import Foundation
import CSDL2
import SwiftSDL2

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

// Draw random rectangles ------------------------------------------------------
func generateRandomRects() -> [SDL_Rect] {
    return (0..<Int32.random(in: 5...10)).map({ _ in
        SDL_Rect(x: .random(in: 0..<width), y: .random(in: 0..<height), w: .random(in: 100..<300), h: .random(in: 100..<300))
    })
}

// Generates a random color
func randomColor() -> SDL_Color {
    SDL_Color(r: .random(in: 0..<(.max)), g: .random(in: 0..<(.max)), b: .random(in: 0..<(.max)), a: 255)
}

// Run Loop (poorly implemented) -----------------------------------------------
var randomRects = generateRandomRects()
var rectColor   = randomColor()
var running     = true
repeat {
    renderer?.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 255)
    renderer?.result(of: SDL_RenderClear)
    var event = SDL_Event()
    while(SDL_PollEvent(&event) != 0) {
        switch Int(event.key.keysym.sym) {
        case SDLK_RETURN:
            rectColor = randomColor()
            if event.key.repeat == 0 && event.key.state == SDL_PRESSED {
                randomRects = generateRandomRects()
            }
        default: ()
        }
        running = (event.type != SDL_QUIT.rawValue)
    }
    SDL_Delay(100) // Prevent 100% CPU usage

    // -------------------------------------------------------------------------
    randomRects.forEach {
        var currectRect = $0
        renderer?.result(of: SDL_SetRenderDrawColor, rectColor.r, rectColor.g, rectColor.b, 255)
        renderer?.result(of: SDL_RenderDrawRect, &currectRect)
    }
    
    // Present buffer ----------------------------------------------------------
    renderer?.pass(to: SDL_RenderPresent)
} while running

// Quit ------------------------------------------------------------------------
SDL.Quit(subSystems: .video)
