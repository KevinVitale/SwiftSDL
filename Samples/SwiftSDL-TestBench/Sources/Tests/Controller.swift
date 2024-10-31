import SwiftSDL

extension SDL.Test {
  final class Controller: Game {
    private enum CodingKeys: String, CodingKey {
      case options
      case useVirtual
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL controller routines"
    )
    
    @OptionGroup var options: Options
    
    @Flag(name: [.customLong("virtual")], help: "Simulate a virtual gamepad.")
    var useVirtual: Bool = false

    static let name: String = "SDL Test: Controller"
    
    func onReady(window: any Window) throws(SDL_Error) {
      try SDL_Init(.joystick)
      
      var desc = SDL_VirtualJoystickDesc(
        type: .gamepad,
        buttons: [.up, .down, .left, .right, .start],
        sensors: [.init(type: SDL_SENSOR_ACCEL, rate: 0.0)]
      )
      
      print("Attaching virtual device...")
      let virtualID = SDL_AttachVirtualJoystick(&desc)
      guard virtualID != 0 else {
        print("Couldn't attach virtual device: \(SDL_GetError() as Any)")
        throw SDL_Error.error
      }
      
      print("Opening virtual device...")
      guard let ptr = SDL_OpenJoystick(virtualID) else {
        print("Couldn't open virtual device: \(SDL_GetError() as Any)")
        throw SDL_Error.error
      }
      
      print("Is Virtual Joystick:", SDL_IsJoystickVirtual(virtualID))
      guard SDL_DetachVirtualJoystick(virtualID) else {
        throw SDL_Error.error
      }
      
      SDL_CloseJoystick(ptr)
    }
    func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
    }
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) { }
    func onShutdown(window: any Window) throws(SDL_Error) { }
  }
}

fileprivate struct Controller {
  enum Axis {
  }
}

