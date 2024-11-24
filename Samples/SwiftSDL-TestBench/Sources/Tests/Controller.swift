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
    private var textures: [String : any Texture] = [:]
    private var scene: GamepadScene<Controller>!
    
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
      let contentScale = (try display.contentScale.get())
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
      
      self.renderer = try window.createRenderer(with: (SDL_PROP_RENDERER_VSYNC_NUMBER, 1))
      self.scene = GamepadScene(size: try renderer.outputSize(as: Float.self))
      self.scene.bgColor = .white
      try self.scene.load(self.renderer)
    }
    
    func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {
      try renderer.draw(scene: scene, updateAt: delta)
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      var event = event
      try renderer(SDL_ConvertEventToRenderCoordinates, .some(&event))
      try scene.handle(event)
    }
    
    func onShutdown(window: (any Window)?) throws(SDL_Error) {
      try scene?.shutdown()
      renderer = nil
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
      try gameController.open()
    }
  }
}

extension SDL.Test.Controller {
  final class GamepadScene<Game: SwiftSDL.Game>: GameScene<any Renderer>, @unchecked Sendable {
    enum Image: String, CaseIterable {
      case gamepadFront = "Gamepad (Front)"
      case gamepadBack = "Gamepad (Back)"
      case faceABXY = "Face (ABXY)"
      case faceBAYX = "Face (BAYX)"
      case faceSony = "Face (Sony)"
      case battery = "Battery"
      case batteryWired = "Battery (Wired)"
      case touchpad = "Touchpad"
      case button = "Button"
      case axis = "Axis"
      case buttonSmall = "Button (Small)"
      case axisArrow = "Axis (Arrow)"
      case glass = "Glass"
      
      var fileName: String {
        switch self {
          case .gamepadFront: return "gamepad_front.bmp"
          case .gamepadBack: return "gamepad_back.bmp"
          case .faceABXY: return "gamepad_face_abxy.bmp"
          case .faceBAYX: return "gamepad_face_bayx.bmp"
          case .faceSony: return "gamepad_face_sony.bmp"
          case .battery: return "gamepad_battery.bmp"
          case .batteryWired: return "gamepad_battery_wired.bmp"
          case .touchpad: return "gamepad_touchpad.bmp"
          case .button: return "gamepad_button.bmp"
          case .axis: return "gamepad_axis.bmp"
          case .buttonSmall: return "gamepad_button_small.bmp"
          case .axisArrow: return "gamepad_axis_arrow.bmp"
          case .glass: return "glass.bmp"
        }
      }
      
      var position: Point<Float> {
        switch self {
          case .gamepadFront: fallthrough
          case .gamepadBack: return Layout.gamepadImagePosition
          case .faceABXY: fallthrough
          case .faceBAYX: fallthrough
          case .faceSony: return Layout.gamepadImagePosition + [363, 118]
          default: return .zero
        }
      }
      
      var zPosition: Float {
        switch self {
          case .gamepadFront: return -2
          case .gamepadBack: return -1
          default: return 0
        }
      }
    }
    
    private var textures: [Image : any Texture] = [:]
    
    public subscript(_ image: Image) -> TextureNode? {
      guard let node = child(matching: image.rawValue) as? TextureNode else {
        guard let texture = textures[image] else {
          return nil
        }
        let node = try! TextureNode(image.rawValue, with: texture)
        node.position = image.position
        node.zPosition = image.zPosition
        self.addChild(node)
        return node
      }
      return node
    }

    private var gameController: GameController {
      guard let gameController = self.gameControllers?.last, case(.open) = gameController else {
        return .invalid
      }
      return gameController
    }
    
    private var gameControllerName: String {
      let joystickID = gameController.id
      let isGamepad = gameController.isGamepad
      let isVirtual = gameController.isVirtual
      
      var text = ""
      
      let GetNameFunc = isGamepad ? SDL_GetGamepadNameForID : SDL_GetJoystickNameForID
      if let controllerName = GetNameFunc(joystickID) {
        text = String(cString: controllerName)
      }
      
      text = isVirtual ? "Virtual Controller" : text
      return text
    }
    
    override func load(_ graphics: any Renderer) throws(SDL_Error) {
      self.textures = Image
        .allCases
        .reduce(into: [:]) {
          if let texture = try? graphics.texture(
            from: try Load(bitmap: $1.fileName),
            tag: $1.rawValue
          ) {
            $0[$1] = texture
          }
        }
      
      self.addChild(TextLabelNode("Placeholder", text: "Waiting for gamepad, press A to add a virtual controller"))
      self.addChild(TextLabelNode("Title"))
      self.addChild(TextLabelNode("Subtitle", text: "Click on the gamepad image below to generate input"))
      self.addChild(TextLabelNode("Controller ID"))
      self.addChild(TextLabelNode("Gamepad Type"))
      self.addChild(TextLabelNode("Steam Handle"))
      self.addChild(TextLabelNode("Button Column", text: "BUTTONS"))
      self.addChild(TextLabelNode("Axises Column", text: "AXES"))
      self.addChild(TextLabelNode("Vendor ID"))
      self.addChild(TextLabelNode("Product ID"))
      self.addChild(TextLabelNode("Serial"))
      
      for btnIdx in SDL_GamepadButton.allCases {
        let xPos = Float(0.0)
        let yPos = 12 + 14 * Float(btnIdx.rawValue)
        
        let text = String("\(btnIdx): ".reversed())
        /*
         .padding(toLength: 10, withPad: " ", startingAt: 0)
         .reversed()
         */
        
        let node = try ButtonPressedNode(
          "Gamepad Button: \(btnIdx)",
          text: String(text).capitalized,
          index: btnIdx.rawValue,
          position: [xPos, yPos], with: self.textures[.buttonSmall]!
        )
        node.position = [xPos, yPos]
        self.addChild(node)
      }
    }
    
    override func update(at delta: Uint64) throws(SDL_Error) {
      try super.update(at: delta)
      
      let invalidGameController = gameController == .invalid
      
      children
        .enumerated()
        .forEach { index, node in
          node.isHidden = invalidGameController

          if let node = node as? TextLabelNode {
            let textSize = node.text.debugTextSize(as: Float.self) / 2
            
            if node.label.contains("Placeholder") {
              node.position = [(size / 2).x, 24] - textSize
              node.isHidden = !invalidGameController
            }
            
            if node.label.contains("Title") {
              node.text = gameControllerName
              node.position = [(size / 2).x, 24] - textSize
            }
            
            if node.label.contains("Subtitle") {
              node.position = [(size / 2).x, 36] - textSize
              node.isHidden = !gameController.isVirtual
            }
            
            if node.label.contains("Gamepad Type") {
              node.text = gameController.isVirtual ? "" : gameController.gamepadType.debugDescription
              node.position = Layout.typeFrame.lowHalf + Layout.typeFrame.highHalf / 2 + [0, -2]
            }

            if node.label.contains("Serial") {
              let text = "Serial: \(gameController.gamepadSerial)"
              if !text.isEmpty {
                node.text = text
                node.position = [(size / 2).x, size.y - 12] - textSize
              }
            }
            
            if node.label.contains("Button Column") {
              node.position = [
                Layout.panelWidth +
                Layout.panelSpacing +
                Layout.gamepadWidth +
                Layout.panelSpacing + 8,
                Layout.titleHeight + 8
              ]
              
              let buttonIndices = gameController.buttonIndices()
              if node.children.count != buttonIndices.count {
                node.removeAllChildren()
              }
              
              for btnIdx in gameController.buttonIndices() {
                let btnIdx = Int32(btnIdx)
                let xPos = Float(0.0)
                let yPos = 12 + 14 * Float(btnIdx)
                
                var button = node.child(matching: "Joystick Button: \(btnIdx)") as? ButtonPressedNode
                
                if button == nil {
                  button = try? ButtonPressedNode(
                    "Joystick Button: \(btnIdx)",
                    text: "".appendingFormat("%2d:", btnIdx),
                    index: btnIdx,
                    position: [xPos, yPos], with: self.textures[.buttonSmall]!
                  )
                  node.addChild(button!)
                }
                
                button?.position = [xPos, yPos]
                button?.isHidden = node.isHidden
                button?.isPressed = gameController.joystick(isPressed: btnIdx)
              }
            }
            
            if node.label.contains("Axises Column") {
              node.position = [
                Layout.panelWidth +
                Layout.panelSpacing +
                Layout.gamepadWidth +
                Layout.panelSpacing + 96,
                Layout.titleHeight + 8
              ]
            }
            
            if node.label.contains("Controller ID") {
              node.text = "(\(gameController.id))"
              node.position = [size.x - 20, 12] - textSize
            }
            
            /*
            if node.label.contains("Steam Handle") {
              node.text = "".appendingFormat("Steam: 0x%.16", gameController.gamepadSteamHandle)
              let textSize = node.text.debugTextSize(as: Float.self) / 2
              node.position = size - [2, 8] - textSize
            }
             */

            if node.label.contains("Vendor ID") {
              let vID = SDL_GetJoystickVendorForID(gameController.id)
              let textSize = node.text.debugTextSize(as: Float.self) / 2
              node.text = "VID: 0x".appendingFormat("%.4X", vID)
              node.position = size - textSize - [textSize.x * 3 + 16, 14]
            }
            
            if let textLabel = self.child(matching: "Product ID") as? TextLabelNode {
              let pID = SDL_GetJoystickProductForID(gameController.id)
              let textSize = textLabel.text.debugTextSize(as: Float.self) / 2
              textLabel.text = "PID: 0x".appendingFormat("%.4X", pID)
              textLabel.position = size - textSize - [52, 14]
            }
          }

          if node.label.contains("Gamepad Button:"), let node = node as? ButtonPressedNode {
            let xPos = Float(128.0)
            let yPos = 64 + 14 * Float(node.button)

            node.position = [xPos, yPos]
            node.isPressed = gameController.gamepad(isPressed: .init(rawValue: node.button))
          }
        }
      
      
      self[.gamepadFront]?.isHidden = invalidGameController
      self[.faceABXY]?.isHidden = invalidGameController || !(gameController.gamepad(labelFor: .south) == .a)
      self[.faceBAYX]?.isHidden = invalidGameController || !(gameController.gamepad(labelFor: .south) == .b)
      self[.faceSony]?.isHidden = invalidGameController || !(gameController.gamepad(labelFor: .south) == .cross)
    }
    
    override func handle(_ event: SDL_Event) throws(SDL_Error) {
      try super.handle(event)
      
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
  }
}

extension SDL.Test.Controller {
  class TextLabelNode: SpriteNode<any Renderer> {
    convenience init(_ label: String, text: String, color: SDL_Color = .black) {
      self.init(label)
      self.text = text
      self.color = color
    }
    
    var text: String = ""
    var color: SDL_Color = .black
    
    override func draw(_ graphics: any Renderer) throws(SDL_Error) {
      try super.draw(graphics)
      
      guard !text.isEmpty else { return }
      try graphics.debug(text: text, position: position, color: color)
    }
  }
  
  final class ButtonPressedNode: TextLabelNode {
    convenience init(_ label: String = "", text: String = "", index button: Int32, position: Point<Float>, color: SDL_Color = .black, with texture: any Texture) throws(SDL_Error) {
      self.init(label, text: text.isEmpty ? "".appendingFormat("%2d:", button) : text, color: color)
      
      self.button = button
      self.position = position
      
      let textureNode = try TextureNode(with: texture)
      textureNode.position = [text.debugTextSize(as: Float.self).x, -2]
      self.addChild(textureNode)
    }
    
    var button: Int32 = -1
    var isPressed: Bool = false

    private var image: TextureNode {
      children.first as! TextureNode
    }
    
    override func draw(_ graphics: any Renderer) throws(SDL_Error) {
      image.colorMod = isPressed ? SDL_Color(r: 10, g: 255, b: 21, a: 255) : .white
      try super.draw(graphics)
    }
  }
  
  final class AxisTriggerNode: SpriteNode<any Renderer> {
  }
  
  final class AccelerometerNode: SpriteNode<any Renderer> {
  }
}

extension SDL.Test.Controller.GamepadScene {
  fileprivate struct GamepadState: Identifiable, Hashable {
    enum Element {
      case button(Int32)
      case axis(Int32)
    }
    
    let id: Int32
    let position: Point<Float>
  }
}

/*
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
 */

/*
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
 */

extension SDL.Test.Controller {
  struct Layout {
    static let titleHeight: Float = 48.0
    static let panelSpacing: Float = 25.0
    static let panelWidth: Float = 250.0
    // static let minimumButtonWidth: Float = 96.0
    static let buttonMargin: Float = 16.0
    static let buttonPadding: Float = 12.0
    static let gamepadWidth: Float = 512.0
    static let gamepadHeight: Float = 560.0
    
    static var gamepadImagePosition: Point<Float> {
      [Self.panelWidth + Self.panelSpacing, Self.titleHeight]
    }
    
    static var titleFrame: Rect<Float> {
      let width = gamepadWidth
      let height = String.debugFontSize(as: Float.self) + 2.0 * Self.buttonMargin
      let xPos = Self.panelWidth + Self.panelSpacing
      let yPos = Self.titleHeight / 2 - height / 2
      return Rect(lowHalf: [xPos, yPos], highHalf: [width, height])
    }
    
    static var typeFrame: Rect<Float> {
      let width = Self.panelWidth - 2 * Self.buttonMargin
      let height = String.debugFontSize(as: Float.self) + 2 * Self.buttonMargin
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
