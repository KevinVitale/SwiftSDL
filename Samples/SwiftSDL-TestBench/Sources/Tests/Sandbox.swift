extension SDL.Test {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey { case options }
    
    @OptionGroup var options: Options
    
    static let name: String = "Kevin's Personal Sandbox"
    private var scene: Scene!
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      scene = Scene(size: try window.size(as: Float.self), bgColor: .gray)
      
      try window.sync(options: options)
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
