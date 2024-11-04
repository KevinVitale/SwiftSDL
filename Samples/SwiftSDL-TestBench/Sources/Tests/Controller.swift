/*
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
    
    private var _scene: ControllerScene!
    
    func onInit() throws(SDL_Error) -> any Window {
      print("Applying SDL Hints...")
      _applyHints()
      
      print("Initializing SDL (v\(SDL_Version()))...")
      try SDL_Init(.video, .gamepad)
      
      let display = try Displays.primary.get()
      let contentScale = (try? display.contentScale.get()) ?? 1
      let screenSize = ControllerScene
        .Layout
        .screenSize(scaledBy: contentScale)
        .to(Sint64.self)

      let window = try SDL_CreateWindow(
        with: .windowTitle(Self.name),
        .width(screenSize.x), .height(screenSize.y)
      )

      return window
    }
    
    func onReady(window: any Window) throws(SDL_Error) {
      // Create the scene; attach it to the window
      self._scene = .init("Root Scene")
      try self._scene.attach(to: window)
    }

    func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
      let renderer = try window.renderer.get()
      try _scene.update(at: delta)
      try _scene.draw(renderer)
      try renderer.present()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      try _scene.handle(event)
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      try _scene.shutdown()
    }
    
    private func _applyHints() {
      #if os(macOS)
      // Wired 360 controller wasn't reported...related?
      // See this issue: https://github.com/libsdl-org/SDL/issues/11002
      SDL_SetHint(SDL_HINT_JOYSTICK_MFI, "0")
      #endif
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS5_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_STEAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ROG_CHAKRAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_LINUX_DEADZONES, "1");
    }
  }
}

*/
