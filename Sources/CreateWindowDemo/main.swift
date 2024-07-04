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
  let (_, renderer) = try engine.addWindow(width: 480, height: 640)
  
  // Print renderer info -----------------------------------------------------
  print(try renderer.info.get())
  
  // Get logical renderer size -----------------------------------------------
  var width: Int32 = .zero, height: Int32 = .zero
  try renderer.result(of: SDL_GetRendererOutputSize, &width, &height).get()
  print("Window Created: \(width) x \(height)")
  
  // Draw random rectangles --------------------------------------------------
  func generateRandomRects(count range: ClosedRange<Int32> = 5...10) -> [SDL_Rect] {
    return (0..<Int32.random(in: range)).map({ _ in
      SDL_Rect(x: .random(in: 0..<width),
               y: .random(in: 0..<height),
               w: .random(in: 100..<300),
               h: .random(in: 100..<300))
    })
  }
  
  // Draw random cirlces --------------------------------------------------
  func generateRandomCircles(count range: ClosedRange<Int32> = 5...10) -> [(x: Sint16, y: Sint16, rad: Sint16, color: SDL_Color)] {
    return (0..<Int32.random(in: range)).map({ _ in
      let x = Sint16((Int16.random(in: 0..<Int16(width))))
      let y = Sint16((Int16.random(in: 0..<Int16(height))))
      let r = Sint16((Int16.random(in: Int16(100)..<Int16(300))))
      let c = randomColor()
      return (x: x, y: y, rad: r, color: c)
    })
  }
  
  // Generates a random color ------------------------------------------------
  func randomColor() -> SDL_Color {
    SDL_Color(r: .random(in: 0..<(.max)),
              g: .random(in: 0..<(.max)),
              b: .random(in: 0..<(.max)),
              a: 255)
  }
  
  // Game state --------------------------------------------------------------
  var randomCircles = generateRandomCircles()
  var randomRects   = generateRandomRects()
  var rectColor     = randomColor()
  
  // Handle input ------------------------------------------------------------
  engine.handleInput = { [weak engine] in
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
      if event.type == SDL_QUIT.rawValue {
        engine?.stop()
      }
      
      switch event.key.keysym.sym {
      case let key where key >= 0: ()
        switch SDL_KeyCode(UInt32(key)) {
        case SDLK_RETURN:
          rectColor = randomColor()
          if event.key.repeat == 0 && event.key.state == SDL_PRESSED {
            randomCircles = generateRandomCircles()
            randomRects = generateRandomRects()
          }
        default: ()
        }
      default: ()
      }
    }
  }
  
  // Render 'rects' ----------------------------------------------------------
  engine.render = {
    renderer.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 255)
    renderer.result(of: SDL_RenderClear)
    
    /*
    randomCircles.forEach {
      var currentCircle = $0
      renderer.result(of: circleColorRGBA,
                      currentCircle.x,
                      currentCircle.y,
                      currentCircle.rad,
                      currentCircle.color.r,
                      currentCircle.color.g,
                      currentCircle.color.b,
                      currentCircle.color.a
      )
    }
     */
     
    randomRects.forEach {
      var currectRect = $0
      renderer.result(of: SDL_SetRenderDrawColor, rectColor.r, rectColor.g, rectColor.b, 255)
      renderer.result(of: SDL_RenderDrawRect, &currectRect)
    }
    
    renderer.pass(to: SDL_RenderPresent)
  }
}
