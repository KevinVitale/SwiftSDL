public final class ControllerScene: BaseScene<any Renderer> {
  private var _frontTexture: (any Texture)!
  private var _backTexture: (any Texture)!
  private var _showBackOfGamepad: Bool = false

  public override func attach(to window: any Window) throws(SDL_Error) {
    try super.attach(to: window)
    
    self.bgColor = .white
    self.size = try window.size(as: Float.self)
    
    var renderer: (any Renderer)!
    
    do {
      renderer = try window.renderer.get()
    } catch {
      /* Create the renderer; clear it; present it; set logical size */
      renderer = try window
        .createRenderer()
        .clear(color: bgColor)
        .present()
        .set(logicalSize: size, presentation: .letterbox)
    }
    
    self._frontTexture = try _createTexture(renderer, &gamepad_front_bmp, gamepad_front_bmp_len)
    self._backTexture = try _createTexture(renderer, &gamepad_back_bmp, gamepad_back_bmp_len)
  }
  
  @MainActor
  private func _createTexture(_ renderer: any Renderer, _ bmp: inout [UInt8], _ length: Int) throws(SDL_Error) -> (any Texture)! {
    guard let srcPtr = SDL_IOFromMem(&bmp, length) else {
      throw SDL_Error.error
    }
    
    guard let pointer = SDL_LoadBMP_IO(srcPtr, true) else {
      throw SDL_Error.error
    }
    
    let surface = SDLObject<SurfacePtr>(pointer: pointer)
    defer { surface.destroy() }
    
    return try renderer.texture(from: surface)
  }
  
  public override func handle(_ event: SDL_Event) throws(SDL_Error) {
    try super.handle(event)
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
  
  public override func shutdown() throws(SDL_Error) {
    _frontTexture.destroy()
    _backTexture.destroy()
  }
  
  override public func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try graphics.clear(color: bgColor)
    switch _showBackOfGamepad {
      case true: try graphics.draw(texture: _frontTexture, position: SceneLayout.gamepadImagePosition)
      case false: try graphics.draw(texture: _backTexture, position: SceneLayout.gamepadImagePosition)
    }
    // try _drawGamepadWaiting(graphics)
  }
  
  @MainActor
  private func _drawGamepadWaiting(_ graphics: any Renderer) throws(SDL_Error) {
    /*
     let text = "Waiting for gamepad, press A to add a virtual controller";
     var x: Int, y: Int;
    
    x = Int((SceneLayout.sceneWidth / 2) - Double(Int(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE) * text.count) / 2)
    y = Int((SceneLayout.sceneWidth / 2) - Double(Int(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)) / 2)
    
    try graphics.debug(text: text, position: [Float(x), Float(y)])
     */
  }
}

extension ControllerScene {
  enum SceneState {
    func draw(_ graphics: any Renderer) throws(SDL_Error) {
    }
  }
}

extension ControllerScene {
  @MainActor
  struct SceneLayout {
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
    
    static func screenSize(scaledBy scale: Float = 1.0) -> Size<Sint64> {
      let scaledSize = Size(x: sceneWidth, y: sceneHeight).to(Float.self) * scale
      let size: Size<Float> = [SDL_ceilf(scaledSize.x), SDL_ceilf(scaledSize.y)]
      return size.to(Sint64.self)
    }
  }
}

/*
fileprivate func _attachVirtualJoystick() throws(SDL_Error) {
  guard case(.invalid) = _virtualJoystick else {
    return
  }
  _virtualJoystick = try Joysticks
    .attachVirtual(
      type: .gamepad,
      name: "Virtual Joystick",
      touchpads: [.init(nfingers: 1, padding: (0, 0, 0))],
      sensors: [.init(type: .accelerometer, rate: 0)]
    )
    .open()
}
*/





