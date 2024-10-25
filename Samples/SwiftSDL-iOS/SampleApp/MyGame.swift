@main public final class MyGame: Game {
  private var squareNode = SceneNode()
  private var squareSize = Size<Float>(x: 100, y: 100)
  
  public init() {
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "Portrait")
    SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, "1")
  }

  public static private(set) var name: String = ""
  public static private(set) var version: String = ""
  public static private(set) var identifier: String = ""
  
  private var scene: CameraScene!

  public func onReady(window: any Window) throws(SDL_Error) {
    try SDL_Init(.camera)
    
    let size = try window.size(as: Float.self)
    scene = try CameraScene(size: size) { camera, _, _ in
      camera.position == .frontFacing
    }
    scene.position = [0, 100]
    scene.size = [320, 240]
  }
  
  public func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
    try scene.update(window: window, at: delta)
    try self.drawSquare(surface: try window.surface.get())
    try window.updateSurface()
  }
  
  private func drawSquare(surface: any Surface) throws(SDL_Error) {
    let squareFrame: SDL_FRect = [
      squareNode.position.x, squareNode.position.y,
      squareSize.x, squareSize.y
    ]
    
    var rect: SDL_Rect = squareFrame.to(Int32.self)
    
    try scene.draw(surface)
    
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
    scene.camera?.destroy()
  }
}
