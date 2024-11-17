extension SDL.Test {
  // final class Sandbox: Game {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey {
      case options
    }
    
    @OptionGroup var options: Options
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try window(SDL_HideWindow)
      try SDL_Init(.joystick)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
    }
    
    func did(add gameController: inout GameController) throws(SDL_Error) {
      print("Added:", gameController, gameController.joystickName, gameController.gamepadName)
      
      if gameControllers.count >= 2 {
        for var gameController in gameControllers {
          try gameController.open()
        }
      }
    }
    
    func will(remove gameController: GameController) {
      print("Closing:", gameController, gameController.joystickName, gameController.gamepadName)
    }
  }
}
