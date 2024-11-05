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
    private var state = State()
    
    func onInit() throws(SDL_Error) -> any Window {
      print("Applying SDL Hints...")
      _applyHints()
      
      print("Initializing SDL (v\(SDL_Version()))...")
      try SDL_Init(.video, .gamepad)
      
      let display = try Displays.primary.get()
      let contentScale = (try? display.contentScale.get()) ?? 1
      let screenSize = Layout
        .screenSize(scaledBy: contentScale)
        .to(Sint64.self)

      let window = try SDL_CreateWindow(
        with: .windowTitle(Self.name),
        .width(screenSize.x), .height(screenSize.y)
      )
      
      return window
    }
    
    func onReady(window: any Window) throws(SDL_Error) {
      renderer = try window.createRenderer(with: (SDL_PROP_RENDERER_VSYNC_NUMBER, 1))
      
      let surfaceFront = try Load(bitmap: "gamepad_front.bmp")
      state.gamepadFront = try renderer.texture(from: surfaceFront)
      
      let surfaceRear = try Load(bitmap: "gamepad_back.bmp")
      state.gamepadRear = try renderer.texture(from: surfaceRear)
    }

    func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {
      try renderer
        .clear(color: .white)
        .fill(rects: [0, 400, 100, 100], color: .green)
        .debug(text: state.display.title, position: state.display.textPosition, color: .black)
        .draw(texture: state.gamepadTexture, position: Layout.gamepadImagePosition)
        .present()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
      switch event.eventType {
        case .keyUp: state.display = .front
        case .keyDown: state.display = .back
        default: ()
      }
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      state = .init()
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
  enum Display {
    case detached
    case front
    case back
    
    @MainActor
    var title: String {
      switch self {
        case .back: return "Back"
        case .front: return "Front"
        case .detached: return "Waiting for gamepad, press A to add a virtual controller"
      }
    }
    
    @MainActor
    var textPosition: Point<Float> {
      let width = (Layout.sceneWidth / 2) - (Float(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE) * Float(SDL_strlen(title)) / 2)
      let height = (Layout.titleHeight / 2) - (Float(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE) / 2)
      
      return [width, height]
    }
  }
  
  struct State {
    var gamepadFront: (any Texture)!
    var gamepadRear: (any Texture)!
    
    var display: Display = .detached
    
    var gamepadTexture: (any Texture)! {
      switch display {
        case .detached: return nil
        case .front: return gamepadFront
        case .back: return gamepadRear
      }
    }
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
