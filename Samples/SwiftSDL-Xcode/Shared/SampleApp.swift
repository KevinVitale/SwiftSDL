import SwiftSDL

@main public final class MyGame: Game {
  private var squareNode = SceneNode()
  private var squareSize = Size<Float>(x: 100, y: 100)
  
  #if os(macOS)
  @Argument(parsing: .allUnrecognized)
  var ignored: [String]
  #endif
  
  public init() {
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "Portrait")
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "metal")
  }
  
  public static let name: String = ""
  public static let version: String = ""
  public static let identifier: String = ""
  
  private var camera: CameraID? = nil
  
  public func onReady(window: any Window) throws(SDL_Error) {
    #if !os(tvOS)
    try SDL_Init(.camera)
    
    camera = try Cameras.matching { camera, _, _ in
      camera.name.contains("FaceTime")
    }
    #endif
  }
  
  public func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
    do {
      let surface = try window.surface.get()
      try surface.clear(color: .gray)
      try camera?.draw(to: surface)
      try self.drawSquare(surface: surface)
      try window.updateSurface()
    }
    catch {
      print("\(#function):", error)
    }
  }
  
  @MainActor
  private func drawSquare(surface: any Surface) throws(SDL_Error) {
    let squareFrame: SDL_FRect = [
      squareNode.position.x, squareNode.position.y,
      squareSize.x, squareSize.y
    ]
    
    var rect: SDL_Rect = squareFrame.to(Int32.self)
    
    let color = try surface.map(color: .green)
    try surface(SDL_FillSurfaceRect, .some(&rect), color)
  }
  
  public func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    switch event.eventType {
      case .fingerDown: fallthrough
      case .fingerMotion:
        let touchPoint = event.tfinger.position(as: Float.self)
        let windowSize = try window.size(as: Float.self)
        var touchTranslated = touchPoint * windowSize
        touchTranslated -= squareSize / 2
        
        squareNode.position = touchTranslated
      default: ()
    }
  }
  
  public func onShutdown(window: any Window) throws(SDL_Error) {
    camera?.close()
  }
}
