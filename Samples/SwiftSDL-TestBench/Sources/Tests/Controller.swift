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
    
    private var gamepad: GamepadNode? {
      willSet {
        gamepad?.removeAllChildren()
      }
    }
    
    private var gameController: GameController {
      gameControllers.last ?? .invalid
    }
    
    private var joystickID: SDL_JoystickID {
      gameController.id
    }
    
    func onInit() throws(SDL_Error) -> any Window {
      print("Applying SDL Hints...")
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS5_RUMBLE, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_STEAM, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_ROG_CHAKRAM, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1")
      SDL_SetHint(SDL_HINT_JOYSTICK_LINUX_DEADZONES, "1")
      SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
      
      /* Enable input debug logging */
      SDL_SetLogPriority(Int32(SDL_LOG_CATEGORY_INPUT.rawValue), SDL_LOG_PRIORITY_DEBUG);

      print("Initializing SDL (v\(SDL_Version()))...")
      try SDL_Init(.video, .joystick)

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
      
      let globalProperties = try SDL_PropertiesID.global()
      for (idx, (key, value)) in try globalProperties.enumerated() {
        print(idx, key, value)
      }

      let windowProperties = try window(SDL_GetWindowProperties)
      for (idx, (key, value)) in try windowProperties.enumerated() {
        print(idx, key, value)
      }
      
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
          if joystickID != .zero,
             let joystick = SDL_GetJoystickFromID(joystickID),
             let btnTexture = gamepad?.btn.texture,
             let arrowTexture = gamepad?.arrow.texture
          {
            try $0.debug(text: title.text, position: title.position, color: .black)
            try $0.debug(text: subtitle.text, position: subtitle.position, color: .black )
            try $0.debug(text: controllerID.text, position: controllerID.position, color: .black )
            try $0.debug(text: gamepadType.text, position: gamepadType.position, color: .black )
            try $0.debug(text: steamHandle.text, position: steamHandle.position, color: .black )
            try $0.debug(text: serial.text, position: serial.position, color: .black )
            try $0.debug(text: buttonsTitle.text, position: buttonsTitle.position, color: .black )
            try $0.debug(text: axisTitle.text, position: axisTitle.position, color: .black )
            try $0.debug(text: vendorID.text, position: vendorID.position, color: .black )
            try $0.debug(text: productID.text, position: productID.position, color: .black )
            
            try drawButtonColumnUI(btnTexture: btnTexture, joystick: joystick, renderer: $0)
            try drawAxesColumnUI(arrowTexture: arrowTexture, joystick: joystick, renderer: $0)
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
      
      if (0x600..<0x800).contains(event.type) {
        for button in gameController.gamepadButtons() {
          print("Button: \(button)", gameController.gamepad(query: button))
        }

        for axis in gameController.gamepadAxes() {
          print("Axis: \(axis)", gameController.gamepad(query: axis))
        }
        
        for sensor in gameController.gamepadSensors() {
          gameController.gamepad(activate: sensor)
          print("Sensor Rate: \(sensor)", gameController.gamepad(rate: sensor))
          print("Sensor Data: \(sensor)", gameController.gamepad(query: sensor))
        }
      }

      switch event.eventType {
        case .keyDown:
          if event.key.key == SDLK_A {
            try SDL_AttachVirtualJoystick(
              type: .gamepad,
              name: "Virtual Controller",
              touchpads: [.init(nfingers: 1, padding: (0, 0, 0))],
              sensors: [
                .init(type: .accelerometer, rate: 0),
                .init(type: .gyroscope, rate: 0),
              ]
            )
          }
          
          else if event.key.key == SDLK_D, gameController.isVirtual {
            var gameController = self.gameController
            gameController.close()
          }
        default: ()
      }
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      gamepad = nil
      renderer = nil
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
      try gameController.open()
      self.gamepad = try .init(id: gameController.id, renderer: renderer)
    }
    
    func will(remove gameController: GameController) {
      if joystickID != .zero, let gamepad = try? GamepadNode(id: joystickID, renderer: renderer) {
        self.gamepad = gamepad
      } else {
        self.gamepad = nil
      }
    }
  }
}


extension SDL.Test.Controller {
  private func drawButtonColumnUI(
    btnTexture: any Texture,
    joystick: OpaquePointer,
    renderer: any Renderer
  ) throws(SDL_Error) {
    let buttonCount = SDL_GetNumJoystickButtons(joystick)
    for btnIdx in 0..<buttonCount {
      var xPos = buttonsTitle.position.x
      var yPos = buttonsTitle.position.y + (Layout.lineHeight + 2) + ((Layout.lineHeight + 4) * Float(btnIdx))
      let text = "".appendingFormat("%2d:", btnIdx)
      try renderer.debug(text: text, position: [xPos, yPos], color: .black)
      
      xPos += 2 + (Layout.fontCharacterSize * Float(SDL_strlen(text)))
      yPos -= 2
      
      if SDL_GetJoystickButton(joystick, Int32(btnIdx)) {
        try btnTexture.set(colorMod: .init(r: 10, g: 255, b: 21, a: 255))
        try renderer.draw(texture: btnTexture, position: [xPos, yPos])
      }
      else {
        try btnTexture.set(colorMod: .white)
        try renderer.draw(texture: btnTexture, position: [xPos, yPos])
      }
    }
  }
  
  private func drawAxesColumnUI(
    arrowTexture: any Texture,
    joystick: OpaquePointer,
    renderer: any Renderer
  ) throws(SDL_Error) {
    let axisCount = SDL_GetNumJoystickAxes(joystick)
    for axisIdx in 0..<axisCount {
      var xPos = axisTitle.position.x - 8
      var yPos = axisTitle.position.y + (Layout.lineHeight + 2) + ((Layout.lineHeight + 4) * Float(axisIdx))
      let text = "".appendingFormat("%2d:", axisIdx)
      try renderer.debug(text: text, position: [xPos, yPos], color: .black)
      
      /* 'RenderJoystickAxisHighlight' ???
       let pressedColor = SDL_Color(r: 175, g: 238, b: 238, a: 255)
       let highlightColor = SDL_Color(r: 224, g: 255, b: 255, a: 255)
       try renderer.fill(rects: [
       xPos + Layout.fontCharacterSize * Float(SDL_strlen(axisTitle.text)) + 2,
       yPos + Layout.fontCharacterSize / 2,
       100,
       100
       ], color: pressedColor)
       */
      
      xPos += 2 + (Layout.fontCharacterSize * Float(SDL_strlen(text)))
      yPos -= 2
      
      let value = SDL_GetJoystickAxis(joystick, axisIdx)
      
      // Left-Arrow (With Highlight State)
      if value == Int16.min {
        try arrowTexture.set(colorMod: .init(r: 10, g: 255, b: 21, a: 255))
        try renderer.draw(texture: arrowTexture, position: [xPos, yPos])
      }
      else {
        try arrowTexture.set(colorMod: .white)
        try renderer.draw(texture: arrowTexture, position: [xPos, yPos], direction: .horizontal)
      }
      
      // Axis Divider Fill
      let arwSize = try arrowTexture.size(as: Float.self)
      try renderer.fill(rects: [
        xPos + 52,
        yPos,
        4.0,
        arwSize.y
      ], color: .init(r: 200, g: 200, b: 200, a: 255)
      )
      
      // Right-Arrow (With Highlight State)
      if value == Int16.max {
        try arrowTexture.set(colorMod: .init(r: 10, g: 255, b: 21, a: 255))
        try renderer.draw(texture: arrowTexture, position: [xPos + 102, yPos])
      }
      else {
        try arrowTexture.set(colorMod: .white)
        try renderer.draw(texture: arrowTexture, position: [xPos + 102, yPos])
      }
    }
  }
}

extension SDL.Test.Controller {
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
  
  private var subtitle: (text: String, position: Point<Float>) {
    guard SDL_IsJoystickVirtual(joystickID) else {
      return ("", .zero)
    }
    
    let subtitle = "Click on the gamepad image below to generate input"
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(subtitle)) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2) + (Layout.fontCharacterSize + 2.0) + 2.0
    
    return (subtitle, [width, height])
  }
  
  private var controllerID: (text: String, position: Point<Float>) {
    let text = "(\(joystickID))"
    
    let width = Layout.sceneWidth - (Layout.fontCharacterSize * Float(SDL_strlen(text))) - 8
    let height: Float = 8.0
    
    return (text, [width, height])
  }
  
  private var gamepadType: (text: String, position: Point<Float>) {
    guard SDL_IsGamepad(joystickID),
          let pointer = SDL_GetGamepadFromID(joystickID) else
    {
      return ("", .zero)
    }
    
    let text = SDL_GetGamepadType(pointer).debugDescription
    
    let width = Layout.typeFrame.x + (Layout.typeFrame.z / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(text))) / 2
    let height = Layout.typeFrame.y + (Layout.typeFrame.w / 2) - (Layout.fontCharacterSize / 2)
    
    return (text, [width, height])
  }
  
  private var steamHandle: (text: String, position: Point<Float>) {
    guard SDL_IsGamepad(joystickID),
          let pointer = SDL_GetGamepadFromID(joystickID) else
    {
      return ("", .zero)
    }
    
    let handle = SDL_GetGamepadSteamHandle(pointer)
    guard handle != 0 else {
      return ("", .zero)
    }
    
    let text = "Steam: 0x\(String(handle, radix: 16, uppercase: true))"
    let width = Layout.sceneWidth - 8 - (Layout.fontCharacterSize * Float(SDL_strlen(text)))
    let height = Layout.sceneHeight - 2 * (8 + Layout.lineHeight)
    
    return (text, [width, height])
  }
  
  private var placeholder: (text: String, position: Point<Float>) {
    let placeholder = "Waiting for gamepad, press A to add a virtual controller"
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(placeholder)) / 2)
    let height = (Layout.titleHeight / 2) - (Layout.fontCharacterSize / 2)
    
    return (placeholder, [width, height])
  }
  
  private var serial: (text: String, position: Point<Float>) {
    let GetDeviceFunc = SDL_IsGamepad(joystickID) ? SDL_GetGamepadFromID : SDL_GetJoystickFromID
    let GetSerialFunc = SDL_IsGamepad(joystickID) ? SDL_GetGamepadSerial : SDL_GetJoystickSerial
    
    guard let pointer = GetDeviceFunc(joystickID),
          let serialPtr = GetSerialFunc(pointer) else {
      return ("", .zero)
    }
    
    let serial = "Serial: \(String(cString: serialPtr))"
    let width = (Layout.sceneWidth / 2) - (Layout.fontCharacterSize * Float(SDL_strlen(serial)) / 2)
    let height = Layout.sceneHeight - 8.0 - Layout.lineHeight
    
    return(serial, [width, height])
  }
  
  private var buttonsTitle: (text: String, position: Point<Float>) {
    let buttonsTitle = "BUTTONS"
    let width = Layout.panelWidth + Layout.panelSpacing + Layout.gamepadWidth + Layout.panelSpacing + 8
    let height = Layout.titleHeight + 8
    
    return (buttonsTitle, [width, height])
  }
  
  private var axisTitle: (text: String, position: Point<Float>) {
    let axesTitle = "AXES"
    let width = Layout.panelWidth + Layout.panelSpacing + Layout.gamepadWidth + Layout.panelSpacing + 96
    let height = Layout.titleHeight + 8
    
    return (axesTitle, [width, height])
  }

  private var vendorID: (text: String, position: Point<Float>) {
    let vID = SDL_GetJoystickVendorForID(joystickID)
    let text = "VID: 0x".appendingFormat("%.4X", vID)
    
    let width = Layout.sceneWidth - 8 - (Layout.fontCharacterSize * Float(SDL_strlen(text))) - (Layout.fontCharacterSize * Float(SDL_strlen(productID.text) + 2))
    let height = Layout.sceneHeight - 8.0 - Layout.lineHeight
    
    return (text, [width, height])
  }
  
  private var productID: (text: String, position: Point<Float>) {
    let pID = SDL_GetJoystickProductForID(joystickID)
    let text = "PID: 0x".appendingFormat("%.4X", pID)
    
    let width = Layout.sceneWidth - 8 - (Layout.fontCharacterSize * Float(SDL_strlen(text)))
    let height = Layout.sceneHeight - 8.0 - Layout.lineHeight
    
    return (text, [width, height])
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
  }
  
  var front: TextureNode { child(matching: "Gamepad (Front)") as! TextureNode }
  var back: TextureNode { child(matching: "Gamepad (Back)") as! TextureNode }
  var btn: TextureNode { child(matching: "Button (Small)") as! TextureNode }
  var arrow: TextureNode { child(matching: "Axis (Arrow)") as! TextureNode }
}

extension SDL.Test.Controller {
  struct Layout {
    static let titleHeight: Float = 48.0
    static let panelSpacing: Float = 25.0
    static let panelWidth: Float = 250.0
    static let lineHeight: Float = fontCharacterSize + 2.0
    // static let minimumButtonWidth: Float = 96.0
    static let buttonMargin: Float = 16.0
    static let buttonPadding: Float = 12.0
    static let gamepadWidth: Float = 512.0
    static let gamepadHeight: Float = 560.0
    static let fontCharacterSize: Float = Float(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)
    
    static var gamepadImagePosition: Point<Float> {
      [Self.panelWidth + Self.panelSpacing, Self.titleHeight]
    }
    
    static var titleFrame: Rect<Float> {
      let width = gamepadWidth
      let height = Self.fontCharacterSize + 2.0 * Self.buttonMargin
      let xPos = Self.panelWidth + Self.panelSpacing
      let yPos = Self.titleHeight / 2 - height / 2
      return Rect(lowHalf: [xPos, yPos], highHalf: [width, height])
    }
    
    static var typeFrame: Rect<Float> {
      let width = Self.panelWidth - 2 * Self.buttonMargin
      let height = Self.fontCharacterSize + 2 * Self.buttonMargin
      let xPos = Self.buttonMargin
      let yPos = Self.titleHeight / 2 - height / 2
      return Rect(lowHalf: [xPos, yPos], highHalf: [width, height])
    }
    
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
    
    static var touchpadFrame: Rect<Float> {
      [148.0, 20.0, 216.0, 118.0]
    };
  }
}
