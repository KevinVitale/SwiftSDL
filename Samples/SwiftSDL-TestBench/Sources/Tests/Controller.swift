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
    
    private var renderer: (any Renderer)!
    
    private var joystickID: SDL_JoystickID = .zero {
      willSet {
        guard joystickID != .zero, joystickID != newValue else {
          return
        }
        
        if SDL_IsJoystickVirtual(joystickID) {
          print("Detaching virtual joystick...")
          SDL_DetachVirtualJoystick(joystickID)
        }
        
        if let pointer = SDL_GetJoystickFromID(joystickID) {
          if SDL_IsGamepad(joystickID) {
            print("Closing gamepad...")
          }
          else {
            print("Closing joystick...")
          }
          
          SDL_CloseJoystick(pointer)
        }
      }
      didSet {
        if joystickID == .zero {
          gamepad = nil
        }
        else {
          if SDL_IsJoystickVirtual(joystickID) {
            print("Virtual joystick attached...")
          }
          
          if SDL_IsGamepad(joystickID) {
            print("Opening gamepad...", SDL_OpenGamepad(joystickID) != nil ? "success" : "failure", separator: "")
          }
          else {
            print("Opening joystick...", SDL_OpenJoystick(joystickID) != nil ? "success" : "failure", separator: "")
          }
        }
      }
    }
    
    private var gamepad: GamepadNode? {
      willSet {
        gamepad?.removeAllChildren()
      }
    }
    
    func onInit() throws(SDL_Error) -> any Window {
      /* Enable input debug logging */
      SDL_SetLogPriority(Int32(SDL_LOG_CATEGORY_INPUT.rawValue), SDL_LOG_PRIORITY_DEBUG);
      
      print("Applying SDL Hints...")
      _applyHints()
      
      print("Initializing SDL (v\(SDL_Version()))...")
      try SDL_Init(.video, .gamepad)
      
      print("Calculate the size of the window....")
      let display = try Displays.primary.get()
      let contentScale = (try? display.contentScale.get()) ?? 1
      let screenSize = Layout
        .screenSize(scaledBy: contentScale)
        .to(Sint64.self)
      
      print("Creating window (\(screenSize.x) x \(screenSize.y))....")
      let window = try SDL_CreateWindow(
        with: .windowTitle(Self.name),
        .width(screenSize.x), .height(screenSize.y)
      )
      
      defer { print("Initializing complete!") }
      return window
    }
    
    func onReady(window: any Window) throws(SDL_Error) {
      print("Creating renderer...")
      renderer = try window.createRenderer(with: (SDL_PROP_RENDERER_VSYNC_NUMBER, 1))
    }
    
    func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {
      SDL_Delay(16)
      try renderer
        .clear(color: .white)
        .draw(node: gamepad)
        .draw(into: {
          if joystickID != .zero {
            try $0.debug(text: title.text, position: title.position, color: .black)
            try $0.debug(text: subtitle.text, position: subtitle.position, color: .black )
            try $0.debug(text: serial.text, position: serial.position, color: .black )
          }
          else {
            try $0.debug(
              text: placeholder.text,
              position: placeholder.position,
              color: .black
            )
          }
        })
        .present()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      var event = event
      try renderer(SDL_ConvertEventToRenderCoordinates, .some(&event))
      
      switch event.eventType {
        case .joystickAdded:
          joystickID = event.jdevice.which
          gamepad = try .init(id: joystickID, renderer: renderer)

        case .joystickRemoved:
          if let joystickID = try SDL_ConnectedJoystickIDs().first {
            self.joystickID = joystickID
            gamepad = try .init(id: joystickID, renderer: renderer)
          }
          else {
            joystickID = .zero
          }
          
        case .joystickAxisMotion: ()
        case .joystickButtonDown: ()
        case .joystickButtonUp: ()
        case .joystickHatMotion: ()
          
        case .gamepadRemapped: ()
        case .gamepadSteamHandleUpdated: ()
        case .gamepadButtonDown: fallthrough
        case .gamepadButtonUp: ()
          
        case .mouseButtonDown: ()
        case .mouseButtonUp: ()
        case .mouseMotion: ()
          
        case .keyDown: ()
          if event.key.key == SDLK_A {
            joystickID = try SDL_AttachVirtualJoystick(
              type: .gamepad,
              touchpads: [.init(nfingers: 1, padding: (0, 0, 0))],
              sensors: [.init(type: .accelerometer, rate: 0)]
            )
            
            gamepad = try .init(id: joystickID, renderer: renderer)
          }
          
          else if event.key.key == SDLK_D, SDL_IsJoystickVirtual(joystickID) {
            joystickID = .zero
          }
        case .keyUp: ()
        case .textInput: ()
          
        default: ()
      }
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      joystickID = .zero
      renderer = nil
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
      SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
    }
  }
}

extension SDL.Test.Controller {
  @MainActor
  private var title: (text: String, position: Point<Float>) {
    let isVirtual = SDL_IsJoystickVirtual(joystickID)
    let isGamepad = SDL_IsGamepad(joystickID)
    
    var displayName: String = ""
    
    let GetNameFunc = isGamepad ? SDL_GetGamepadNameForID : SDL_GetJoystickNameForID
    if let controllerName = GetNameFunc(joystickID) {
      displayName = String(cString: controllerName)
    }
    
    displayName = isVirtual ? "Virtual Controller" : displayName
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(displayName)) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2)
    
    return (displayName, [width, height])
  }
  
  @MainActor
  private var subtitle: (text: String, position: Point<Float>) {
    guard SDL_IsJoystickVirtual(joystickID) else {
      return ("", .zero)
    }
    
    let subtitle = "Click on the gamepad image below to generate input"
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(subtitle)) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2) + (Layout.fontCharacterSize + 2.0) + 2.0
    
    return (subtitle, [width, height])
  }
  
  @MainActor
  private var placeholder: (text: String, position: Point<Float>) {
    let placeholder = "Waiting for gamepad, press A to add a virtual controller"
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(placeholder)) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2)
    
    return (placeholder, [width, height])
  }
  
  @MainActor
  private var serial: (text: String, position: Point<Float>) {
    guard let pointer = SDL_GetJoystickFromID(joystickID),
          let serialPtr = SDL_GetJoystickSerial(pointer) else {
      return ("", .zero)
    }
    
    let serial = String(cString: serialPtr)
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(serial)) / 2)
    let height = Layout.sceneHeight - 8.0 - Layout.fontCharacterSize
    
    print(serial)
    return(serial, [width, height])
  }
}

final class GamepadNode: TextureNode {
  required init(_ label: String = "Gamepad") {
    super.init(label)
  }
  
  required init(_ label: String = "Gamepad", with texture: any Texture, size: Size<Float>) {
    super.init(label, with: texture, size: size)
  }
  
  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  private var joystickID: SDL_JoystickID = .zero
  
  @MainActor
  convenience init(id joystickID: SDL_JoystickID, renderer: any Renderer) throws(SDL_Error) {
    self.init("Gamepad")
    self.joystickID = joystickID
    
    self.addChild(
      try TextureNode(
        "Gamepad (Front)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_front.bmp"),
        renderer: renderer
      )
    )?.zPosition = -1
    
    self.addChild(
      try TextureNode(
        "Gamepad (Back)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_back.bmp"),
        renderer: renderer
      )
    )?.zPosition = -2
    
    self.addChild(
      try TextureNode(
        "Face (ABXY)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_face_abxy.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Face (BAYX)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_face_bayx.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Face (Sony)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_face_sony.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Battery",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_battery.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Battery (Wired)",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_battery_wired.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Touchpad",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_touchpad.bmp"),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Button",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_button.bmp"),
        colorMod: .init(r: 10, g: 255, b: 21, a: 255),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Axis",
        position: SDL.Test.Controller.Layout.gamepadImagePosition,
        surface: try Load(bitmap: "gamepad_axis.bmp"),
        colorMod: .init(r: 10, g: 255, b: 21, a: 255),
        renderer: renderer
      )
    )
    
    self.addChild(
      try TextureNode(
        "Button (Small)",
        position: .zero,
        surface: try Load(bitmap: "gamepad_button_small.bmp"),
        renderer: renderer
      )
    )?.zPosition = 6
    
    self.addChild(
      try TextureNode(
        "Axis (Arrow)",
        position: [10, 10],
        surface: try Load(bitmap: "gamepad_axis_arrow.bmp"),
        renderer: renderer
      )
    )?.zPosition = 6
    
    for i in SDL_GamepadButton.allCases {
      print(i.debugDescription.capitalized)
    }
  }
  
  var front: TextureNode { child(matching: "Gamepad (Front)") as! TextureNode }
  var back: TextureNode { child(matching: "Gamepad (Back)") as! TextureNode }
  var btn: TextureNode { child(matching: "Button (Small)") as! TextureNode }
}

extension SDL.Test.Controller {
  @MainActor
  static var joystickIDTextPosition: Point<Float> {
    let width: Float = Layout.sceneWidth - (Layout.fontCharacterSize * Float(SDL_strlen(""))) - 8
    let height: Float = 8
    return [width, height]
  }
  
  @MainActor
  static var titleTextPosition: Point<Float> {
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen("")) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2)
    return [width, height]
  }
  
  @MainActor
  static var subtitleTextPosition: Point<Float> {
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen("")) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2) + (Layout.fontCharacterSize + 2.0) + 2.0
    return [width, height]
  }
  
  @MainActor
  static var miscTextPosition: Point<Float> {
    let width = Layout.sceneWidth - 8.0 - (Layout.fontCharacterSize * Float(SDL_strlen("")))
    let height = Layout.sceneHeight - 8.0 - Layout.fontCharacterSize
    return [width, height]
  }
  @MainActor
  static var serialTextPosition: Point<Float> {
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen("")) / 2)
    let height = Layout.sceneHeight - 8.0 - Layout.fontCharacterSize
    return [width, height]
  }
  
  struct Layout {
    static let titleHeight: Float = 48.0
    static let panelSpacing: Float = 25.0
    static let panelWidth: Float = 250.0
    static let minimumButtonWidth: Float = 96.0
    static let buttonMargin: Float = 16.0
    static let buttonPadding: Float = 12.0
    static let gamepadWidth: Float = 512.0
    static let gamepadHeight: Float = 560.0
    static let fontCharacterSize: Float = Float(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)
    
    static var gamepadImagePosition: Point<Float> {
      [Self.panelWidth + Self.panelSpacing, Self.titleHeight]
    }
    
    static var titleFrame: Rect<Float> {
      var width = gamepadWidth
      var height = Self.fontCharacterSize + 2.0 * Self.buttonMargin
      var xPos = Self.panelWidth + Self.panelSpacing
      var yPos = Self.titleHeight / 2 - height / 2
      
      width = Self.panelWidth - 2 * Self.buttonMargin
      height = Self.fontCharacterSize + 2 * Self.buttonMargin
      xPos = Self.buttonMargin
      yPos = Self.titleHeight / 2 - height / 2
      
      return Rect(lowHalf: [xPos, yPos], highHalf: [width, height])
    }
    
    static var gamepadDisplayArea: Rect<Float> {
      [
        0, Self.titleHeight,
        Self.panelWidth, Self.gamepadHeight
      ]
    }
    
    static var gamepadTypeDisplayArea: Rect<Float> {
      [
        0, Self.titleHeight,
        Self.panelWidth, Self.gamepadHeight
      ]
    }
    
    @MainActor
    static let sceneWidth = panelWidth
    + panelSpacing
    + gamepadWidth
    + panelSpacing
    + panelWidth
    
    @MainActor
    static let sceneHeight = titleHeight
    + gamepadHeight
    
    @MainActor
    static func screenSize(scaledBy scale: Float = 1.0) -> Size<Sint64> {
      let scaledSize = Size(x: sceneWidth, y: sceneHeight).to(Float.self) * scale
      let size: Size<Float> = [SDL_ceilf(scaledSize.x), SDL_ceilf(scaledSize.y)]
      return size.to(Sint64.self)
    }
  }
}

extension SDL.Test.Controller {
  final class Button: SpriteNode<any Renderer> {
    enum State: Equatable {
      case highlighted
      case pressed
    }
  }
}
