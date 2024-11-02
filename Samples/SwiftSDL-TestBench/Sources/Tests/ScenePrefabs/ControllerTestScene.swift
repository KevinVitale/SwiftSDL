public final class ControllerTestScene: BaseScene<any Renderer> {
  public override func attach(to window: any Window) throws(SDL_Error) {
    try super.attach(to: window)

    self.size = try window.size(as: Float.self)
    
    /* Create the renderer; clear it; present it; set logical size */
    try window
      .createRenderer()
      .clear(color: bgColor)
      .present()
      .set(logicalSize: size, presentation: .letterbox)
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
  
  override public func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try graphics.clear(color: bgColor)
    try _drawGamepadWaiting(graphics)
  }
  
  @MainActor
  private func _drawGamepadWaiting(_ graphics: any Renderer) throws(SDL_Error) {
    let text = "Waiting for gamepad, press A to add a virtual controller";
    var x: Int, y: Int;
    
    x = Int((SceneLayout.sceneWidth / 2) - Double(Int(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE) * text.count) / 2)
    y = Int((SceneLayout.sceneWidth / 2) - Double(Int(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)) / 2)
    
    try graphics.set(color: .black)
    try graphics(SDL_RenderDebugText, Float(x), Float(y), text)
  }
}

extension ControllerTestScene {
  @MainActor
  struct SceneLayout {
    static let titleHeight = 48.0
    static let panelSpacing = 25.0
    static let panelWidth = 250.0
    static let minimumButtonWidth = 96.0
    static let buttonMargin = 16.0
    static let buttonPadding = 12.0
    static let gamepadWidth = 512.0
    static let gamepadHeight = 560.0
    
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
