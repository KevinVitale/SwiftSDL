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
    
    private var _joysticks: [JoystickID] = []
    
    func onInit() throws(SDL_Error) -> any Window {
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS5_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_STEAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ROG_CHAKRAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_LINUX_DEADZONES, "1");
      
      try SDL_Init(.video, .joystick, .gamepad)

      let display = try Displays.primary.get()
      let contentScale = (try? display.contentScale.get()) ?? 1
      let screenSize = SceneLayout.screenSize(scaledBy: contentScale)
      
      let window = try SDL_CreateWindow(
        with: .windowTitle(Self.name),
        .width(screenSize.x), .height(screenSize.y)
      )
      
      try window
        .createRenderer()
        .clear(color: .white)
        .present()
        .set(logicalSize: screenSize, presentation: .letterbox)

      return window
    }
    
    func onReady(window: any Window) throws(SDL_Error) {
      try Joysticks
        .attachVirtual(
          type: .gamepad,
          name: "Virtual Joystick",
          touchpads: [.init(nfingers: 1, padding: (0, 0, 0))],
          sensors: [.init(type: .accelerometer, rate: 0)]
        )
        .open()
      
      for joystick in (try Joysticks.connected.get()) {
        _joysticks.append(try joystick.open())
      }
      
      _joysticks.forEach {
        let vID = String($0.vendorID, radix: 16)
        let pID = String($0.productID, radix: 16)
        print($0, "0x\(vID)", "0x\(pID)", $0.serial)
      }
    }
    
    func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
      let renderer = try window.renderer.get()
      try renderer.clear(color: .white)
      try renderer.present()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      switch event.eventType {
        case .joystickAdded: ()
        case .joystickRemoved: ()
        case .joystickAxisMotion: ()
        case .joystickButtonDown: ()
        case .joystickButtonUp: ()
        case .joystickHatMotion: ()
        case .gamepadAdded: ()
        case .gamepadRemoved: ()
        case .gamepadRemapped: ()
        case .gamepadSteamHandleUpdated: ()
        case .gamepadButtonDown: ()
        case .gamepadButtonUp: ()
        case .mouseButtonDown: ()
        case .mouseButtonUp: ()
        case .mouseMotion: ()
        case .keyDown: ()
        case .textInput: ()
        default: ()
      }
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      for var joystick in _joysticks {
        try joystick.close()
      }
    }
  }
}

extension SDL.Test.Controller {
  struct SceneLayout {
    static let titleHeight = 48.0
    static let panelSpacing = 25.0
    static let panelWidth = 250.0
    static let minimumButtonWidth = 96.0
    static let buttonMargin = 16.0
    static let buttonPadding = 12.0
    static let gamepadWidth = 512.0
    static let gamepadHeight = 560.0
    
    static let sceneWidth = panelWidth
    + panelSpacing
    + gamepadWidth
    + panelSpacing
    + panelWidth
    
    static let sceneHeight = titleHeight
    + gamepadHeight
    
    static func screenSize(scaledBy scale: Float = 1.0) -> Size<Sint64> {
      let scaledSize = Size(x: sceneWidth, y: sceneHeight).to(Float.self) * scale
      let size: Size<Float> = [SDL_ceilf(scaledSize.x), SDL_ceilf(scaledSize.y)]
      return size.to(Sint64.self)
    }
  }
}
