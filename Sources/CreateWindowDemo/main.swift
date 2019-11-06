import Foundation
import CSDL2
import SwiftSDL2

try SDL.Run { engine in
    // Start engine ------------------------------------------------------------
    try engine.start(subsystems: .video)
    
    // Print render driver info ------------------------------------------------
    SDLRenderer.rendererInfo().forEach {
        print($0)
    }
    
    // Create renderer ---------------------------------------------------------
    let (_, renderer) = try engine.addWindow(width: 640, height: 480)

    // Print renderer info -----------------------------------------------------
    print(try renderer.info.get())
    
    // Get logical renderer size -----------------------------------------------
    var width: Int32 = .zero, height: Int32 = .zero
    try renderer.result(of: SDL_GetRendererOutputSize, &width, &height).get()
    print("Window Created: \(width) x \(height)")
    
    // Draw random rectangles --------------------------------------------------
    func generateRandomRects() -> [SDL_Rect] {
        return (0..<Int32.random(in: 5...10)).map({ _ in
            SDL_Rect(x: .random(in: 0..<width), y: .random(in: 0..<height), w: .random(in: 100..<300), h: .random(in: 100..<300))
        })
    }
    
    // Generates a random color ------------------------------------------------
    func randomColor() -> SDL_Color {
        SDL_Color(r: .random(in: 0..<(.max)), g: .random(in: 0..<(.max)), b: .random(in: 0..<(.max)), a: 255)
    }
    
    // Game state --------------------------------------------------------------
    var randomRects = generateRandomRects()
    var rectColor   = randomColor()

    // Handle input ------------------------------------------------------------
    engine.handleInput = { [weak engine] in
        var event = SDL_Event()
        while(SDL_PollEvent(&event) != 0) {
            if event.type == SDL_QUIT.rawValue {
                engine?.stop()
            }
            
            switch Int(event.key.keysym.sym) {
            case SDLK_RETURN:
                rectColor = randomColor()
                if event.key.repeat == 0 && event.key.state == SDL_PRESSED {
                    randomRects = generateRandomRects()
                }
            default: ()
            }
        }
    }
    
    // Render 'rects' ----------------------------------------------------------
    engine.render = {
        renderer.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 255)
        renderer.result(of: SDL_RenderClear)
        
        randomRects.forEach {
            var currectRect = $0
            renderer.result(of: SDL_SetRenderDrawColor, rectColor.r, rectColor.g, rectColor.b, 255)
            renderer.result(of: SDL_RenderDrawRect, &currectRect)
        }
        
        renderer.pass(to: SDL_RenderPresent)
    }
}

