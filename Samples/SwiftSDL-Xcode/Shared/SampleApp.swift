import SwiftSDL

@main public final class MyGame: Game {
  enum CodingKeys: CodingKey { case ignored }
  
  private var square = Square(size: [100, 100])
  
  #if os(macOS)
  @Argument(parsing: .allUnrecognized)
  var ignored: [String]
  #endif
  
  public init() {
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "Portrait")
    SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "metal")
  }
  
  public static let name: String = ""
  public static let version: String = ""
  public static let identifier: String = ""
  
  // private var camera: CameraID? = nil
  
  public func onReady(window: any Window) throws(SDL_Error) {
    /*
    #if !os(tvOS)
    try SDL_Init(.camera)
    
    camera = try Cameras.matching { camera, _, _ in
      camera.name.contains("FaceTime")
    }
    #endif
     */
  }
  
  public func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {
    do {
      let surface = try window.surface.get()
      try surface.clear(color: .gray)
      // try camera?.draw(to: surface)
      try self.drawSquare(surface: surface)
      try window.updateSurface()
    }
    catch {
      print("\(#function):", error)
    }
  }
  
  private func drawSquare(surface: any Surface) throws(SDL_Error) {
    var rect: SDL_Rect = square.rect.to(Int32.self)
    
    let color = try surface.map(color: .green)
    try surface(SDL_FillSurfaceRect, .some(&rect), color)
  }
  
  public func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    switch event.eventType {
      case .mouseMotion:
        let mousePos = event.motion.position(as: Float.self)
        square.position = mousePos - square.size / 2
        
      case .fingerDown: fallthrough
      case .fingerMotion:
        let touchPoint = event.tfinger.position(as: Float.self)
        let windowSize = try window.size(as: Float.self)
        var touchTranslated = touchPoint * windowSize
        touchTranslated -= square.size / 2
        square.position = touchTranslated
        
      default: ()
    }
  }
  
  public func onShutdown(window: (any Window)?) throws(SDL_Error) {
    // camera?.close()
  }
}

extension MyGame {
  struct Square {
    var position: Point<Float> = .zero
    var size: Size<Float> = .zero
    var color: SDL_Color = .green
    
    var rect: SDL_FRect {
      SDL_FRect(x: position.x, y: position.y, w: size.x, h: size.y)
    }
  }
}
