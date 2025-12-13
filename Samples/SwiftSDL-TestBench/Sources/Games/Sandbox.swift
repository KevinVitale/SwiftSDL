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
    private var gamepad: Gamepad = .invalid
    
    func willInit() throws(SDL_Error) {
      SDL_SetHint(SDL_HINT_TRACKPAD_IS_TOUCH_ONLY, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1")
    }
    
    func onReady(window: any SwiftSDL.Window) throws(SDL_Error) {
      let rect = SDL_Rect()
      rect.isEmpty
      scene = SurfaceScene(size: try window.size(as: Float.self), bgColor: .gray)
    }
    
    func onUpdate(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      guard let scene = scene else { return }
      try window.draw(scene: scene, updateAt: Uint64(deltaTime))
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      try scene?.handle(event)
      #if os(macOS)
      switch event.eventType {
        case .mouseButtonUp where event.button.clicks == 1: window.userData?["rnd"] = nil
        case .mouseButtonUp where event.button.clicks == 2:
          try Joystick.attach(name: "Virtual Joystick")
        case .mouseButtonDown where event.button.clicks == 1: window.userData?["rnd"] = self.deltaTime
        default: ()
      }
      #endif
      
      switch (event.eventType, gamepad) {
        case (.gamepadButtonUp, _):
          try gamepad.rumble(UInt16.zero..<UInt16.zero, duration: 0)
        case (.gamepadButtonDown, let gamepad):
          try gamepad.rumble(UInt16.min..<UInt16.max, duration: .max)
        default: break
      }
      
      if event.button.clicks == 1 {
        SDL_Log(event.motion.position(as: Float.self))
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?, failure: GameLoopFailure) {
      try? scene?.shutdown()
    }
    
    func did(add gamepad: inout Gamepad) throws(SDL_Error) {
      guard !gamepad.isVirtual else {
        return
      }
      try gamepad.open()
      self.gamepad = gamepad
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

