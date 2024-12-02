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
    private var scene: GamepadScene!
    
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
      self.scene.textures = try ImageFiles.load(renderer)
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
      scene?.gameController = gameController
    }
    
    func will(remove gameController: GameController) {
      scene?.gameController = self.gameControllers.last ?? .invalid
    }
  }
}

extension SDL.Test.Controller {
  enum ImageFiles: String, CaseIterable {
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
    
    var zPosition: Float {
      switch self {
        case .gamepadFront: return -2
        case .gamepadBack: return -1
        default: return 1
      }
    }
    
    fileprivate static func load(_ graphics: any Renderer) throws(SDL_Error) -> [Self : any Texture] {
      Self
        .allCases
        .reduce(into: [:]) {
          if let texture = try? graphics.texture(
            from: try Load(bitmap: $1.fileName),
            tag: $1.rawValue
          ) {
            $0[$1] = texture
          }
        }
    }
  }
}

extension SDL.Test.Controller {
  final class GamepadScene: GameScene<any Renderer>, @unchecked Sendable {
    enum Label {
      case vendorID(GameController)
      case productID(GameController)
      case controllerID(GameController)
      
      var gameController: GameController {
        switch self {
          case .vendorID(let gameController): return gameController
          case .productID(let gameController): return gameController
          case .controllerID(let gameController): return gameController
        }
      }
      
      var label: String {
        switch self {
          case .vendorID: return "Vendor ID"
          case .productID: return "Product ID"
          case .controllerID: return "Controller ID"
        }
      }
      
      var text: String {
        switch self {
          case .vendorID(let gameController):
            let vID = SDL_GetJoystickVendorForID(gameController.id)
            let text = "VID: 0x".appendingFormat("%.4x", vID)
            return text
          case .productID(let gameController):
            let pID = SDL_GetJoystickProductForID(gameController.id)
            let text = "PID: 0x".appendingFormat("%.4x", pID)
            return text
          case .controllerID(let gameController):
            let cID = gameController.id
            let text = "(\(cID))"
            return text
        }
      }
    }
    
    var textures: [ImageFiles : any Texture] = [:]
    var gameController: GameController = .invalid

    private subscript(_ image: ImageFiles) -> TextureNode? {
      guard let node = child(matching: image.rawValue) as? TextureNode else {
        guard let texture = textures[image] else {
          return nil
        }
        let node = try! TextureNode(image.rawValue, with: texture)
        node.zPosition = image.zPosition
        self.addChild(node)
        return node
      }
      return node
    }
    
    public subscript(_ label: Label) -> DebugTextNode? {
      guard let node = child(matching: label.label) as? DebugTextNode else {
        let node = DebugTextNode(label.label)
        node.text = label.text
        self.addChild(node)
        return node
      }
      node.text = label.text
      return node
    }

    public subscript(_ gamepad: GamepadImageNode.Gamepad) -> GamepadImageNode? {
      guard let node = child(matching: gamepad.label) as? GamepadImageNode else {
        let node = GamepadImageNode(gamepad, textures: textures)
        self.addChild(node)
        return node
      }
      node.gamepad = gamepad
      return node
    }
      
    public subscript(_ list: GamepadListNode.List) -> GamepadListNode? {
      guard let node = child(matching: list.label) as? GamepadListNode else {
        let node = GamepadListNode(list, textures: textures)
        self.addChild(node)
        return node
      }
      node.list = list
      return node
    }
    
    /*
    override func load(_ graphics: any Renderer) throws(SDL_Error) {
      // Load all the textures into the renderer
      // self.textures = try ImageFiles.load(graphics)
      
      /*
      self.addChild(DebugTextNode("Placeholder", text: "Waiting for gamepad, press A to add a virtual controller"))
      self.addChild(DebugTextNode("Title"))
      self.addChild(DebugTextNode("Subtitle", text: "Click on the gamepad image below to generate input"))
      self.addChild(DebugTextNode("Controller ID"))
      self.addChild(DebugTextNode("Gamepad Type"))
      self.addChild(DebugTextNode("Steam Handle"))
      self.addChild(DebugTextNode("Button Column", text: "BUTTONS"))
      self.addChild(DebugTextNode("Axises Column", text: "AXES"))
      self.addChild(DebugTextNode("Vendor ID"))
      self.addChild(DebugTextNode("Product ID"))
      self.addChild(DebugTextNode("Serial"))

      // Go through all the possible gamepad buttons
      // Add them as drawable nodes to the scene
      for btnIdx in SDL_GamepadButton.allCases {
        var text = String.init(repeating: " ", count: 20)
        let btnText = String("\(btnIdx):")
        let startIndex = text.index(text.endIndex, offsetBy: -btnText.count)
        text.replaceSubrange(startIndex..., with: btnText)
                             
        let node = try ButtonPressedNode(
          "Gamepad Button: \(btnIdx)",
          text: String(text),
          index: btnIdx.rawValue,
          position: .zero,
          with: self.textures[.buttonSmall]!
        )
        node.textAlignment = .left
        self.addChild(node)
        
        // Create a button highlight
        let highlightTexture = self.textures[.button]!
        let textureSize = try highlightTexture.size(as: Float.self)
        let button = try TextureNode("Button Highlight: \(btnIdx.rawValue)", with: highlightTexture)
        button.position = btnIdx.position + Layout.gamepadImagePosition - (textureSize / 2)
        button.isHidden = true
        
        self.addChild(button)
      }
       */
    }
     */
    
    /*
    private func layout() throws(SDL_Error) {
      self[.gamepadFront]?.isHidden = isWaitingsForGamepad
      self[.gamepadFront]?.position = [275, 48]
      
      self[.faceABXY]?.isHidden = isWaitingsForGamepad || !(gameController.gamepad(labelFor: .south) == .a)
      self[.faceBAYX]?.isHidden = isWaitingsForGamepad || !(gameController.gamepad(labelFor: .south) == .b)
      self[.faceSony]?.isHidden = isWaitingsForGamepad || !(gameController.gamepad(labelFor: .south) == .cross)
      
      self[.faceABXY]?.position = (self[.gamepadFront]?.position ?? .zero) + [363, 118]
      self[.faceBAYX]?.position = (self[.gamepadFront]?.position ?? .zero) + [363, 118]
      self[.faceSony]?.position = (self[.gamepadFront]?.position ?? .zero) + [363, 118]

      self["Placeholder"]?.position = [size.x / 2, 24]
      self["Placeholder"]?.isHidden = !isWaitingsForGamepad
      
      self["Title"]?.text = gameControllerName
      self["Title"]?.position = [size.x / 2, 24]
      self["Title"]?.isHidden = isWaitingsForGamepad
      
      self["Subtitle"]?.position = [size.x / 2, 36]
      self["Subtitle"]?.isHidden = !gameController.isVirtual
      
      self["Gamepad Type"]?.text = gameController.isVirtual ? "VIRTUAL" : gameController.gamepadType.debugDescription
      self["Gamepad Type"]?.position = [125, 24]
      self["Gamepad Type"]?.isHidden = isWaitingsForGamepad
      
      self["Serial"]?.isHidden = isWaitingsForGamepad
      self["Serial"]?.position = [size.x / 2, size.y - 12]
      self["Serial"]?.text = "Serial: \(gameController.gamepadSerial)"
      
      self["Controller ID"]?.text = "(\(gameController.id))"
      self["Controller ID"]?.isHidden = isWaitingsForGamepad
      self["Controller ID"]?.position = [size.x - 20, 12]
      
      let vID = SDL_GetJoystickVendorForID(gameController.id)
      self["Vendor ID"]?.text = "VID: 0x".appendingFormat("%.4X", vID)
      self["Vendor ID"]?.position = size - [150, 14]
      self["Vendor ID"]?.isHidden = isWaitingsForGamepad
      
      let pID = SDL_GetJoystickProductForID(gameController.id)
      self["Product ID"]?.text = "PID: 0x".appendingFormat("%.4X", pID)
      self["Product ID"]?.position = size - [52, 14]
      self["Product ID"]?.isHidden = isWaitingsForGamepad
      
      /*
      if node.label.contains("Steam Handle") {
        node.text = "".appendingFormat("Steam: 0x%.16", gameController.gamepadSteamHandle)
        let textSize = node.text.debugTextSize(as: Float.self) / 2
        node.position = size - [2, 8] - textSize
      }
       */
      
      if let node = self["Button Column"] {
        node.isHidden = isWaitingsForGamepad
        node.position = [848, 60]
        
        let buttonIndices = gameController.joystickButtons()
        if node.children.count != buttonIndices.count {
          node.removeAllChildren()
        }
        
        for btnIdx in buttonIndices {
          let btnIdx = Int32(btnIdx)
          // let xPos = Float(-16.0)
          let xPos = Float(-4)
          let yPos = 16 + 14 * Float(btnIdx)
          
          var button = node.child(matching: "Joystick Button: \(btnIdx)") as? ButtonPressedNode
          
          if button == nil {
            button = try? ButtonPressedNode(
              "Joystick Button: \(btnIdx)",
              text: "".appendingFormat("%2d:", btnIdx),
              index: btnIdx,
              position: [xPos, yPos],
              with: self.textures[.buttonSmall]!
            )
            node.addChild(button!)
          }
          button?.textAlignment = .left
          button?.position = [xPos, yPos]
          button?.isHidden = node.isHidden
          button?.isPressed = gameController.joystick(isPressed: btnIdx)
        }
        
      }
      
      if let node = self["Axises Column"] {
        node.isHidden = isWaitingsForGamepad
        node.position = [924, 60]

        let axesIndices = gameController.joystickAxes()
        if node.children.count != axesIndices.count {
          node.removeAllChildren()
        }
        
        for axisIdx in axesIndices {
          let axisIdx = Int32(axisIdx)
          let xPos = Float(-12.0)
          let yPos = 12 + 14 * Float(axisIdx)
          
          var axis = node.child(matching: "Axis Index: \(axisIdx)") as? AxisInputNode
          
          if axis == nil {
            axis = try? AxisInputNode(
              "Axis Button: \(axisIdx)",
              text: "".appendingFormat("%2d:", axisIdx),
              position: [xPos, yPos],
              with: self.textures[.axisArrow]!
            )
            node.addChild(axis!)
          }
          
          axis?.isHidden = node.isHidden
          axis?.value = gameController.joystick(axis: axisIdx)
        }
      }
      
      self.children
        .filter { $0.label.contains("Gamepad Button") }
        .compactMap { $0 as? ButtonPressedNode }
        .forEach { node in
          let button = SDL_GamepadButton(rawValue: node.button)
          let yPos = Float(node.button * 14)
          node.isHidden = !gameController.gamepad(has: button)
          node.isPressed = gameController.gamepad(isPressed: button)
          node.position = [8, 40 + yPos] + (self["Gamepad Type"]?.position ?? .zero)
        }

      self.children
        .filter { $0.label.contains("Button Highlight:") }
        .compactMap { $0 as? TextureNode }
        .forEach {
          let indexAsString = $0.label.components(separatedBy: ": ").last
          guard let indexAsInt32 = indexAsString.map(Int32.init(_:)) ?? SDL_GamepadButton.invalid.rawValue else {
            return
          }
          let button = SDL_GamepadButton(rawValue: indexAsInt32)
          let isPressed = gameController.gamepad(isPressed: button)
          $0.isHidden = !isPressed
          $0.colorMod = !isPressed ? .white : SDL_Color(r: 10, g: 255, b: 21, a: 255)
        }
    }
     */
    
    override func update(at delta: Uint64) throws(SDL_Error) {
      try super.update(at: delta)
      
      self[.front(gameController)]?.position = [275, 48]
      self[.back(gameController)]?.position = [275, 48]

      self[.all(gameController)]?.position = [10, 20]
      self[.buttons(gameController)]?.position = [820, 56]
      self[.hats(gameController)]?.position = [200, 200]
      self[.axes(gameController)]?.position = [908, 56]
      
      self[.vendorID(gameController)]?.position = size - [148, 14]
      self[.productID(gameController)]?.position = size - [52, 14]
      
      if let cID = self[.controllerID(gameController)] {
        let textSize = cID.text.debugTextSize(as: Float.self)
        let textPosition: Point<Float> = [size.x - (textSize / 2).x - 8, 12]
        self[.controllerID(gameController)]?.position = textPosition
      }
    }
    
    override func handle(_ event: SDL_Event) throws(SDL_Error) {
      try super.handle(event)
      
      let showFront = UInt32(event.key.mod) & SDL_KMOD_SHIFT == 0
      self[.front(gameController)]?.isHidden = !showFront
      self[.back(gameController)]?.isHidden = showFront
      
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
  final class GamepadImageNode: SpriteNode<any Renderer> {
    enum Gamepad {
      case front(GameController)
      case back(GameController)
      case invalid
      
      var gameController: GameController {
        switch self {
          case .front(let gameController): return gameController
          case .back(let gameController): return gameController
          case .invalid: return .invalid
        }
      }
      
      var label: String {
        switch self {
          case .front: return "Gamepad (Front)"
          case .back: return "Gamepad (Back)"
          case .invalid: return "Gamepad (Invalid)"
        }
      }
      
      var text: String {
        switch self {
          case .front: return ""
          case .back: return ""
          case .invalid: return ""
        }
      }
    }
    
    var gamepad: Gamepad = .invalid
    
    private weak var frontImage: (any Texture)?
    private weak var backImage: (any Texture)?
    private weak var abxy: (any Texture)?
    private weak var bayx: (any Texture)?
    private weak var sony: (any Texture)?
    private weak var highlight: (any Texture)?
    
    private let pressedColor: SDL_Color = SDL_Color(r: 10, g: 255, b: 21, a: 255)

    required init(_ gamepad: Gamepad, textures: [ImageFiles : any Texture]) {
      self.gamepad = gamepad
      self.frontImage = textures[.gamepadFront]
      self.backImage = textures[.gamepadBack]
      self.abxy = textures[.faceABXY]
      self.bayx = textures[.faceBAYX]
      self.sony = textures[.faceSony]
      self.highlight = textures[.button]
      super.init(gamepad.label)
    }
    
    required init(from decoder: any Decoder) throws {
      try super.init(from: decoder)
    }
    
    public required init(_ label: String = "") {
      super.init(label)
    }
    
    public required init(_ label: String = "", position: Point<Float> = .zero, size: Size<Float> = .zero, color: SDL_Color) {
      super.init(label, position: position, color: .black)
    }
    
    override func draw(_ graphics: any Renderer) throws(SDL_Error) {
      switch gamepad {
        case .front(let gameController) where gameController != .invalid:
          let texturePosition = self.position
          let textureSize = (try frontImage?.size(as: Float.self)) ?? .zero
          try frontImage?.draw(dstRect: [
            texturePosition.x, texturePosition.y,
            textureSize.x, textureSize.y
          ])

          let title = "THIS IS THE TITLE"
          let titleSize = title.debugTextSize(as: Float.self) / 2
          let titlePosition = texturePosition - [0, 32] + [textureSize.x / 2, 0] - [titleSize.x, 0]
          try graphics.debug(text: title, position: titlePosition)

          if gameController.isVirtual {
            let subtitle = "Click on the gamepad image below to generate input"
            let textPosition = position - [-56, 16]
            try graphics.debug(text: subtitle, position: textPosition)
          }
          
          for gamepadButton in SDL_GamepadButton.allCases {
            let texturePosition = position - [25, 25] + gamepadButton.position
            let textureSize = (try highlight?.size(as: Float.self)) ?? .zero
            
            switch gameController.gamepad(isPressed: gamepadButton) {
              case true:
                try highlight?.set(colorMod: pressedColor)
                try highlight?.draw(dstRect: [
                  texturePosition.x, texturePosition.y,
                  textureSize.x, textureSize.y
                ])
              case false:
                try highlight?.set(colorMod: .white)
            }
          }

          switch gameController.gamepad(labelFor: .south) {
            case .a:
              let texturePosition = position + [363, 118]
              let textureSize = (try abxy?.size(as: Float.self)) ?? .zero
              try abxy?.draw(dstRect: [
                texturePosition.x, texturePosition.y,
                textureSize.x, textureSize.y
              ])
            case .b:
              let texturePosition = position + [363, 118]
              let textureSize = (try bayx?.size(as: Float.self)) ?? .zero
              try bayx?.draw(dstRect: [
                texturePosition.x, texturePosition.y,
                textureSize.x, textureSize.y
              ])
            case .cross:
              let texturePosition = position + [363, 118]
              let textureSize = (try sony?.size(as: Float.self)) ?? .zero
              try sony?.draw(dstRect: [
                texturePosition.x, texturePosition.y,
                textureSize.x, textureSize.y
              ])
            default: ()
          }
          
        case .back(let gameController) where gameController != .invalid:
          let texturePosition = position
          let textureSize = (try backImage?.size(as: Float.self)) ?? .zero
          try backImage?.draw(dstRect: [
            texturePosition.x, texturePosition.y,
            textureSize.x, textureSize.y
          ])
        default: ()
      }
      
      try super.draw(graphics)
    }
  }
}

extension SDL.Test.Controller {
  final class GamepadListNode: SpriteNode<any Renderer> {
    enum List {
      case buttons(GameController)
      case axes(GameController)
      case hats(GameController)
      case all(GameController)
      case empty
      
      var gameController: GameController {
        switch self {
          case .buttons(let gameController): return gameController
          case .axes(let gameController): return gameController
          case .hats(let gameController): return gameController
          default: return .invalid
        }
      }
      
      var label: String {
        switch self {
          case .all: return "All List"
          case .buttons: return "Button List"
          case .hats: return "Hat List"
          case .axes: return "Axises List"
          default: return "Empty List"
        }
      }
      
      var title: String {
        switch self {
          case .all(let gameController): return name(for: gameController)
          case .buttons: return "BUTTONS"
          case .hats: return "HATS"
          case .axes: return "AXES"
          default: return ""
        }
      }
      
      private func name(for gameController: GameController) -> String {
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
    }
    
    var list: List = .empty
    
    private weak var smallButtonTexture: (any Texture)?
    private weak var arrowTexture: (any Texture)?

    private let pressedColor: SDL_Color = SDL_Color(r: 10, g: 255, b: 21, a: 255)
    
    required init(_ list: List, textures: [ImageFiles : any Texture]) {
      self.list = list
      self.smallButtonTexture = textures[.buttonSmall]
      self.arrowTexture = textures[.axisArrow]
      super.init(list.label)
    }
    
    required init(from decoder: any Decoder) throws {
      try super.init(from: decoder)
    }
    
    public required init(_ label: String = "") {
      super.init(label)
    }
    
    public required init(_ label: String = "", position: Point<Float> = .zero, size: Size<Float> = .zero, color: SDL_Color) {
      super.init(label, position: position, color: .black)
    }
    
    override func draw(_ graphics: any Renderer) throws(SDL_Error) {
      switch list {
        case .buttons(let gameController) where gameController != .invalid:
          try graphics.debug(text: list.title, position: position)
          for button in gameController.joystickButtons() {
            let text = String("\(button):").padded(width: 3)
            let position = position + [0, 12] + [0, 14 * Float(button)]
            try graphics.debug(text: text, position: position)
            
            let texturePosition = position + [2, -10] + text.debugTextSize(as: Float.self)
            let textureSize = (try smallButtonTexture?.size(as: Float.self)) ?? .zero
            
            switch gameController.joystick(isPressed: button) {
              case true: try smallButtonTexture?.set(colorMod: pressedColor)
              case false: try smallButtonTexture?.set(colorMod: .white)
            }
            
            try smallButtonTexture?.draw(dstRect: [
              texturePosition.x, texturePosition.y,
              textureSize.x, textureSize.y
            ])
          }
          
        case .axes(let gameController) where gameController != .invalid:
          try graphics.debug(text: list.title, position: position)
          for axis in gameController.joystickAxes() {
            let text = String("\(axis):").padded(width: 3)
            let position = position + [-8, 12] + [0, 14 * Float(axis)]
            try graphics.debug(text: text, position: position)
          }
          
        case .hats(let gameController) where gameController != .invalid:
          try graphics.debug(text: list.title, position: position)
          let count = gameController.joystickHats()
          try graphics.debug(text: "\(count)", position: position + [0, 24])
          
        case .all(let gameController) where gameController != .invalid:
          try graphics.debug(text: list.title, position: position)
          for gamepadButton in SDL_GamepadButton.allCases {
            let text = String("\(gamepadButton):").padded(width: 18)
            let position = position + [-12, 24] + [0, 14 * Float(gamepadButton.rawValue)]
            try graphics.debug(text: text, position: position)
            
            let texturePosition = position + [2, -10] + text.debugTextSize(as: Float.self)
            let textureSize = (try smallButtonTexture?.size(as: Float.self)) ?? .zero
            
            switch gameController.gamepad(isPressed: gamepadButton) {
              case true: try smallButtonTexture?.set(colorMod: pressedColor)
              case false: try smallButtonTexture?.set(colorMod: .white)
            }
            
            try smallButtonTexture?.draw(dstRect: [
              texturePosition.x, texturePosition.y,
              textureSize.x, textureSize.y
            ])
          }
        default: ()
      }

      try super.draw(graphics)
    }
  }
  
  final class ButtonPressedNode: DebugTextNode {
    convenience init(_ label: String = "", text: String = "", index button: Int32, position: Point<Float>, color: SDL_Color = .black, with texture: any Texture) throws(SDL_Error) {
      self.init(label, text: text.isEmpty ? "".appendingFormat("%2d:", button) : text, color: color)
      
      self.button = button
      self.position = position
      
      let textureNode = try TextureNode(with: texture)
      textureNode.position = [2, -10]
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
  
  final class AxisInputNode: DebugTextNode {
    convenience init(_ label: String = "", text: String = "", position: Point<Float>, color: SDL_Color = .black, with texture: any Texture) throws(SDL_Error) {
      self.init(label, text: text.isEmpty ? "".appendingFormat("%2d:", 0) : text, color: color)
      
      self.position = position

      let arwSize = try texture.size(as: Float.self)
      
      self.addChild(try TextureNode("Left Arrow", with: texture))
      self.addChild(RectangleNode<Graphics>(
        "Value Bar",
        color: SDL_Color(r: 8, g: 200, b: 16, a: 255))
      )
      self.addChild(RectangleNode<Graphics>(
        "Divider",
        size: [4, arwSize.y],
        color: SDL_Color(r: 200, g: 200, b: 200, a: 255))
      )
      self.addChild(try TextureNode("Right Arrow", with: texture))
      
      leftArrow.position = [14, -6]
      leftArrow.flipMode = .horizontal
      
      rightArrow.position = [116, -6]
      rightArrow.zPosition = 2

      divider.position = [66, -6]
      
      valueBar.position = .zero
      valueBar.zPosition = 1
    }
    
    var value: Sint16 = 0

    private var leftArrow: TextureNode {
      child(matching: "Left Arrow") as! TextureNode
    }
    
    private var rightArrow: TextureNode {
      child(matching: "Right Arrow") as! TextureNode
    }
    
    private var divider: RectangleNode<Graphics> {
      child(matching: "Divider") as! RectangleNode<Graphics>
    }
    
    private var valueBar: RectangleNode<Graphics> {
      child(matching: "Value Bar") as! RectangleNode<Graphics>
    }

    override func draw(_ graphics: any Renderer) throws(SDL_Error) {
      leftArrow.colorMod = value == Int16.min ? SDL_Color(r: 10, g: 255, b: 21, a: 255) : .white
      rightArrow.colorMod = value == Int16.max ? SDL_Color(r: 10, g: 255, b: 21, a: 255) : .white
      
      var width: Float = 0
      if value < 0 { width = Float(value) / Float(Int16.min) * -48 }
      if value > 0 { width = Float(value) / Float(Int16.max) * 48 }

      valueBar.size = [width, 6]
      valueBar.position = [68, -3]
      
      try super.draw(graphics)
    }
  }
  
  final class AccelerometerNode: SpriteNode<any Renderer> {
  }
}

extension SDL.Test.Controller {
  struct Layout {
    static let titleHeight: Float = 48.0
    static let panelSpacing: Float = 25.0
    static let panelWidth: Float = 250.0
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

extension SDL_GamepadButton {
  fileprivate var position: Point<Float> {
    switch self {
      case .south: return [413, 190] /* SDL_GAMEPAD_BUTTON_SOUTH */
      case .east: return [456, 156] /* SDL_GAMEPAD_BUTTON_EAST */
      case .west: return [372, 159] /* SDL_GAMEPAD_BUTTON_WEST */
      case .north: return [415, 127] /* SDL_GAMEPAD_BUTTON_NORTH */
      case .back: return [199, 157] /* SDL_GAMEPAD_BUTTON_BACK */
      case .guide: return [257, 153] /* SDL_GAMEPAD_BUTTON_GUIDE */
      case .start: return [314, 157] /* SDL_GAMEPAD_BUTTON_START */
      case .leftStick: return [98, 177] /* SDL_GAMEPAD_BUTTON_LEFT_STICK */
      case .rightStick: return [331, 254] /* SDL_GAMEPAD_BUTTON_RIGHT_STICK */
      case .leftShoulder: return [102, 65] /* SDL_GAMEPAD_BUTTON_LEFT_SHOULDER */
      case .rightShoulder: return [421, 61] /* SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER */
      case .up: return [179, 213] /* SDL_GAMEPAD_BUTTON_DPAD_UP */
      case .down: return [179, 274] /* SDL_GAMEPAD_BUTTON_DPAD_DOWN */
      case .left: return [141, 242] /* SDL_GAMEPAD_BUTTON_DPAD_LEFT */
      case .right: return [211, 242] /* SDL_GAMEPAD_BUTTON_DPAD_RIGHT */
      case .misc1: return [257, 199] /* SDL_GAMEPAD_BUTTON_MISC1 */
      case .rightPaddle1: return [157, 160] /* SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1 */
      case .leftPaddle1: return [355, 160] /* SDL_GAMEPAD_BUTTON_LEFT_PADDLE1 */
      case .rightPaddle2: return [157, 200] /* SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2 */
      case .leftPaddle2: return [355, 200] /* SDL_GAMEPAD_BUTTON_LEFT_PADDLE2 */
      default: return .zero
    }
  }
}

extension String {
  fileprivate func padded(width: Int) -> String {
    guard width > count else {
      return self
    }
    
    var text = String.init(repeating: " ", count: width)
    let startIndex = text.index(text.endIndex, offsetBy: -self.count)
    
    text.replaceSubrange(startIndex..., with: self)
    return text
  }
}
