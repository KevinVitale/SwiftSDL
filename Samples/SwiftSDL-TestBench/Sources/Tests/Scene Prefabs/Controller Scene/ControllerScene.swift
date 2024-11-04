/*
import func Foundation.autoreleasepool

public final class ControllerScene: BaseScene<any Renderer> {
  private var _virtualJoystick: JoystickID!
  
  private weak var _gamepad: GamepadNode!
  private weak var _button: SpriteNodeRendered!
  private weak var _arrow: SpriteNodeRendered!
  
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
    
    /*
    do {
      try self._loadImages()
    }
    catch {
    }
    
    self._virtualJoystick = try .virtualJoystick()
     */
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
      case .keyDown: _gamepad?.showRearImage.toggle()
      case .textInput: ()
      default: ()
    }
  }
  
  public override func shutdown() throws(SDL_Error) {
    try self._virtualJoystick?.close()
  }
  
  override public func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try graphics.clear(color: bgColor)
    try super.draw(graphics)
    try graphics.present()
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
 */
 
/*
extension ControllerScene {
  @MainActor
  private static var _imageCache: [String: (any Texture)?] = [:]
}

extension ControllerScene {
  fileprivate func _loadImages() throws {
    // try autoreleasepool {
      let gamepadFront = try Load(bitmap: "gamepad_front.bmp")
      let gamepadRear = try Load(bitmap: "gamepad_back.bmp")
      let buttonImage = try Load(bitmap: "gamepad_button_small.bmp")
      let arrowImage = try Load(bitmap: "gamepad_axis_arrow.bmp")
    // }
  }
}

extension JoystickID {
  fileprivate static func virtualJoystick(name: String = "Virtual Joystick") throws(SDL_Error) -> JoystickID {
    try Joysticks
      .attachVirtual(
        type: .gamepad,
        name: name,
        touchpads: [.init(nfingers: 1, padding: (0, 0, 0))],
        sensors: [.init(type: .accelerometer, rate: 0)]
      )
      .open()
  }
}
 */
