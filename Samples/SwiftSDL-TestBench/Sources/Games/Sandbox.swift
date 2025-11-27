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
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      scene = SurfaceScene(size: try window.size(as: Float.self), bgColor: .gray)
      SDL_SetLogLevel(.category(.application, priority: .critical))
      SDL_SetLogLevel(.category(.input, priority: .critical))

      SDL_SetHint(SDL_HINT_VIDEO_DRIVER, "software")
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1")
    }
    
    func onUpdate(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      guard let scene = scene else { return }
      try window.draw(scene: scene, updateAt: Uint64(deltaTime))
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      try scene?.handle(event)
      switch event.eventType {
        case .mouseButtonUp where event.button.clicks == 1: window.userData?["rnd"] = nil
        case .mouseButtonUp where event.button.clicks == 2:
          try Joystick.attach(name: "Virtual Joystick")
        case .mouseButtonDown where event.button.clicks == 1: window.userData?["rnd"] = self.deltaTime
        default: ()
      }
      
      if (0x600..<0x800).contains(event.type) {
        do {
          var joystick = try Joystick.locate(fromID: event.jdevice.which).get()
          if joystick.isGamepad {
            switch event.eventType {
              case .joystickAdded:
                try joystick.open()
                /*
                 print(try joystick.playerIndex.get())
                 print(try joystick.GUIDInfo.get())
                 print(try joystick.name.get())
                 print(try joystick.properties.get())
                 print(try joystick.serial.get())
                 print(try joystick.type.get())
                 print(try joystick.vendor.get())
                 print(try joystick[balls: joystick.balls].get())
                 */
                try joystick.rumble(0..<UInt16.max, duration: 500)
              case .joystickRemoved: try joystick.close()
              case .joystickButtonUp: print(try joystick[buttons: joystick.buttons].get())
              case .joystickButtonDown:
                print(try joystick[buttons: joystick.buttons].get())
                try joystick.set(playerIndex: (0..<4).randomElement()!)
                print(try joystick.playerIndex.get())
                try joystick.triggers(0..<UInt16.max, duration: 500)
              case .joystickAxisMotion:
                print(try joystick[axis: joystick.axes].get())
              default: break
            }
          }
          else {
            var gamepad = try _Gamepad.locate(fromID: event.gdevice.which).get()
            switch event.eventType {
              case .gamepadAdded:
                try gamepad.open()
                /*
                 print(try joystick.playerIndex.get())
                 print(try joystick.GUIDInfo.get())
                 print(try joystick.name.get())
                 print(try joystick.properties.get())
                 print(try joystick.serial.get())
                 print(try joystick.type.get())
                 print(try joystick.vendor.get())
                 print(try joystick[balls: joystick.balls].get())
                 */
                try gamepad.rumble(0..<UInt16.max, duration: 500)
              case .gamepadRemoved: try gamepad.close()
              case .gamepadButtonUp: print(try gamepad[buttons: gamepad.buttons].get())
              case .gamepadButtonDown:
                print(try gamepad[buttons: gamepad.buttons].get())
                try gamepad.set(playerIndex: (0..<4).randomElement()!)
                print(try gamepad.playerIndex.get())
                try gamepad.triggers(0..<UInt16.max, duration: 500)
              case .gamepadAxisMotion:
                print(try gamepad[axis: gamepad.axes].get())
              default: break
            }
          }
          
        }
        catch {
          print(error)
        }
      }
      
      if event.button.clicks == 1 {
        SDL_Log(event.motion.position(as: Float.self))
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?, failure: GameLoopFailure) {
      try? scene?.shutdown()
    }
    
    func did(connect gameController: inout Gamepad) throws(SDL_Error) {
      // try gameController.open()
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

