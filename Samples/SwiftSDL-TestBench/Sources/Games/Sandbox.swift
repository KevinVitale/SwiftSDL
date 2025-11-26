extension SDL.Games {
  final class Sandbox: GameLoop {
    enum CodingKeys: CodingKey {
      case options
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Kevin's Personal Sandbox"
    )
    
    static let name: String = "Kevin's Personal Sandbox"

    @OptionGroup var options: Options
    
    private var scene: SurfaceScene!
    
    func willInitWindow() throws(SDL_Error) {
    }
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      scene = SurfaceScene(size: try window.size(as: Float.self), bgColor: .gray)
      
      SDL_SetLogLevel(.category(.video, priority: .trace))
      SDL_SetHint(SDL_HINT_VIDEO_DRIVER, "software")
    }
    
    func onUpdate(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      guard let scene = scene else { return }
      try window.draw(scene: scene, updateAt: Uint64(deltaTime))
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      try scene?.handle(event)
      switch event.eventType {
        case .mouseButtonUp where event.button.clicks == 1: window.userData?["rnd"] = nil
        case .mouseButtonDown where event.button.clicks == 1: window.userData?["rnd"] = self.deltaTime
        default: ()
      }
      
      if event.button.clicks == 1 {
        SDL_Log(event.motion.position(as: Float.self))
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?, failure: GameLoopFailure) {
      try? scene?.shutdown()
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
      try gameController.open()
    }
  }
}

extension SDL.Games.Sandbox {
  class SurfaceScene: GameScene<any Surface> {
    var square: RectangleNode<Graphics>? {
      guard let square = children.first as? RectangleNode<Graphics> else {
        let square = RectangleNode<Graphics>(size: [100, 100], color: .green)
        self.addChild(square)
        return square
      }
      return square
    }
    
    override func handle(_ event: SDL_Event) throws(SDL_Error) {
      switch event.eventType {
        case .mouseMotion:
          let position = event.motion.position(as: Float.self)
          let offset = (square?.size ?? .zero) / 2
          square?.position = position - offset
        case .mouseButtonUp:
          square?.color = .green
        case .mouseButtonDown:
          square?.color = event.button.down ? .yellow : .green
        default: ()
      }
    }
  }
}
