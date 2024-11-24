extension SDL.Test {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey { case options }
    @OptionGroup var options: Options
    
    static let name: String = "Kevin's Personal Sandbox"
    private var scene: Scene!
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      scene = Scene(size: try window.size(as: Float.self), bgColor: .gray)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      try window.draw(scene: scene, updateAt: delta)
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      try scene.handle(event)
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      try scene.shutdown()
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
      try gameController.open()
      print("Added:", gameController, gameController.joystickName, gameController.gamepadName)
    }
    
    func will(remove gameController: GameController) {
      print("Closing:", gameController, gameController.joystickName, gameController.gamepadName)
    }
  }
}

extension SDL.Test.Sandbox {
  class Scene: GameScene<any Surface> {
    class SquareNode: SpriteNode<Graphics> {
      convenience init(_ label: String = "", size: Size<Float>, color: SDL_Color) {
        self.init(label)
        self.size = size
        self.color = color
      }
      
      var size: Size<Float> = .zero
      var color: SDL_Color = .white
      var rect: SDL_Rect {
        let rect: SDL_FRect = [
          position.x, position.y,
          size.x, size.y
        ]
        return rect.to(Int.self)
      }
      
      override func draw(_ graphics: any Surface) throws(SDL_Error) {
        try graphics.fill(rects: rect, color: color)
      }
    }
    
    var square: SquareNode? {
      guard let square = children.first as? SquareNode else {
        let square = Scene.SquareNode(size: [100, 100], color: .green)
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
