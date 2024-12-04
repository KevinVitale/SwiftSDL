///
public protocol Game: AnyObject, ParsableCommand {
  /// The name of the application (“My Game 2: Bad Guy’s Revenge!”).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_NAME_STRING_.
  static var name: String { get }
  
  /// The version of the application (“1.0.0beta5” or a git hash, or whatever makes sense).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_VERSION_STRING_.
  static var version: String { get }
  
  /// A unique string in reverse-domain format that identifies this app (“com.example.mygame2”).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_IDENTIFIER_STRING_.
  static var identifier: String { get }
  
  /// The default window properties  for creating the main window.
  static var windowProperties: [WindowProperty] { get }
  
  var options: GameOptions { get }
  
  func onInit() throws(SDL_Error) -> any Window
  func onReady(window: any Window) throws(SDL_Error)
  func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error)
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error)
  func onShutdown(window: (any Window)?) throws(SDL_Error)
  func onQuit(_ result: SDL_Error?)
  
  func did(connect gameController: inout GameController) throws(SDL_Error)
  func will(remove gameController: GameController)
}

nonisolated(unsafe)
internal var GameControllers: [GameController] = []

extension Game {
  public static var name: String { "\(Self.self)" }
  public static var version: String { "" }
  public static var identifier: String { "" }
  public static var windowProperties: [WindowProperty] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640),
      .hidden(true),
    ]
  }
  
  public var gameControllers: [GameController] {
    GameControllers
  }
  
  public func run() throws {
    App.game = self
    
    guard SDL_SetAppMetadata(
      Self.name,
      Self.version,
      Self.identifier)
    else {
      throw SDL_Error.error
    }
    
    SDL_RunApp(CommandLine.argc, CommandLine.unsafeArgv, { argc, argv in
      SDL_EnterAppMainCallbacks(argc, argv, { state, argc, argv in
        /* onInit */
        do {
          App.window = try App.game.onInit()
          try App.game.onReady(window: App.window)
          try App.window.sync(options: App.game.options)
          try App.window(SDL_ShowWindow)
          
          return .continue
        } catch {
          return .failure
        }
      }, /* onIterate */ { state in
        do {
          let ticks = SDL_GetTicksNS()
          if App.ticks == .max {
            App.ticks = ticks
          }
          
          let delta = ticks - App.ticks
          App.ticks = ticks
          try App.game.onUpdate(window: App.window, delta)

          return .continue
        } catch {
          return .failure
        }
      }, /* onEvent */ { state, event in
        guard let event = event?.pointee else {
          return .failure
        }
        do {
          guard event.type != SDL_EVENT_QUIT.rawValue else {
            return .success
          }
          
          if (0x600..<0x800).contains(event.type) {
            switch event.eventType {
              case .joystickAdded:   fallthrough
              case .joystickRemoved: fallthrough
              case .gamepadAdded:    fallthrough
              case .gamepadRemoved:
                let gameControllers = GameControllers
                GameControllers = try SDL_BufferPointer(SDL_GetJoysticks).map(\.gameController)
                
                let difference = GameControllers
                  .difference(from: gameControllers, by: { existing, new in existing.id == new.id })
                  .inferringMoves()
                
                try difference
                  .forEach {
                    switch($0) {
                      case .insert(_, var gameController, _):
                        try App.game.did(connect: &gameController)
                        
                      case .remove(_, var gameController, _):
                        App.game.will(remove: gameController)
                        gameController.close()
                    }
                  }

              default: ()
            }
          }
          
          try App.game.onEvent(window: App.window, event)
          return .continue
        } catch {
          return .failure
        }
      }, /* onQuit */ { state, result in
        let error: SDL_Error? = (result == .failure ? .error : nil)
        if let error = error, !error.debugDescription.isEmpty {
          debugPrint(error)
        }
        
        defer { App.window = nil }
        try? App.game.onShutdown(window: App.window)
        
        for var gameController in GameControllers {
          gameController.close()
        }
        GameControllers = []
        
        App.game.onQuit(error)
      })
      
      return 0
    }, nil)
  }
  
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(.video)
    return try SDL_CreateWindow(with: Self.windowProperties)
  }
  
  public func onQuit(_ result: SDL_Error?) {
    SDL_Quit()
  }
  
  /// Get the global SDL properties.
  /// - returns: Either global properties, or a _SDL_Error_ failure.
  /// - seealso: _SDL_GetGlobalProperties_
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    let global = SDL_GetGlobalProperties()
    guard global != .zero else {
      return .failure(.error)
    }
    return .success(global)
  }
  
  /// Set a property in the global properties group.
  /// - parameters:
  ///   - property: The property to modify.
  ///   - value: The new value of the property.
  /// - returns: The _SDL_PropertiesID_ for the group being modified.
  /// - seealso: _SDL_SetStringProperty_; _SDL_SetFloatProperty_; _SDL_SetBooleanProperty_; _SDL_SetNumberProperty_; _SDL_SetPointerProperty_.
  @discardableResult
  public func set<P: PropertyValue>(property: String, value: P) throws(SDL_Error) -> SDL_PropertiesID {
    let properties = try self.properties.get()
    guard properties.set(property, value: value) else {
      throw SDL_Error.error
    }
    return properties
  }

  public func did(connect gameController: inout GameController) throws(SDL_Error) { /* no-op */ }
  public func will(remove gameController: GameController) { /* no-op */ }
}

public struct GameOptions: ParsableArguments {
  public init() { }
  
  @Flag(help: "Hide the system's cursor")
  public var hideCursor: Bool = false
  
  @Flag(help: "Stretch the content to fill the window")
  public var autoScaleContent: Bool = false
  
  @Option(help: "Forces the rendered content to be a certain logical size (WxH)")
  public var logicalSize: SDL_Size? = nil
  
  @Option(help: "Forces the rendered content to be a certain logical order; overrides '--auto-scale-content'")
  public var logicalPresentation: SDL_RendererLogicalPresentation = .disabled
  
  @Option(name: .customLong("vsync-rate"), help: "Set vertical synchronization rate")
  public var vsync: VSyncRate = .disabled
  
  @Flag(help: "Window is always kept on top")
  public var windowAlwaysOnTop: Bool = false
  
  @Flag(help: "Create a maximized window; requires '--window-resizable'")
  public var windowMaximized: Bool = false
  
  @Flag(help: "Create a minimized window")
  public var windowMinimized: Bool = false
  
  @Option(help: "Specify the maximum window's size (WxH)")
  public var windowMaxSize: SDL_Size?
  
  @Option(help: "Specify the minimum window's size (WxH)")
  public var windowMinSize: SDL_Size?
  
  @Flag(help: "Force the window to have mouse focus")
  public var windowMouseFocus: Bool = false
  
  @Flag(help: "Create a borderless window")
  public var windowNoFrame: Bool = false
  
  @Flag(help: "Enable window resizability")
  public var windowResizable: Bool = false
  
  @Option(help: "Specify the window's position (XxY)")
  public var windowPosition: SDL_Point?
  
  @Option(help: "Specify the window's size (WxH)")
  public var windowSize: SDL_Size?
  
  @Option(help: "Specify the window's title")
  public var windowTitle: String?
}

extension GameOptions {
  public enum VSyncRate: RawRepresentable, ExpressibleByArgument, Decodable {
    public init?(argument: String) {
      switch argument.lowercased() {
        case "adaptive": self = .adaptive
        case let value where Int(value) != nil:
          let value = Int32(value)!
          self = value != 0 ? .enabled(value) : .disabled
        default: self = .disabled
      }
    }
    
    public init?(rawValue: Int32) {
      switch rawValue {
        case -1: self = .adaptive
        case 0: self = .disabled
        default: self = .enabled(rawValue)
      }
    }
    
    case adaptive
    case disabled
    case enabled(Int32)
    
    public var rawValue: RawValue {
      switch self {
        case .adaptive: return -1
        case .enabled(let value): return value
        case .disabled: return 0
      }
    }
    
    public var defaultValueDescription: String {
      switch self {
        case .adaptive: return "adaptive"
        case .enabled: return "enabled"
        case .disabled: return "disabled"
      }
    }
    
    public static var allValueStrings: [String] {
      [
        "adaptive",
        "disabled",
        "interger value"
      ]
    }
  }
}

extension SDL_Point: @retroactive ExpressibleByArgument {
  public init?(argument: String) {
    let width = Int32(argument.split(separator: "x").first ?? "0") ?? .zero
    let height = Int32(argument.split(separator: "x").last ?? "0") ?? .zero
    self.init(x: width, y: height)
  }
}

extension SDL_RendererLogicalPresentation: @retroactive ExpressibleByArgument {
  public init?(argument: String) {
    switch argument.lowercased() {
      case "stretch": self = .stretch
      case "letterbox": self = .letterbox
      case "overscan": self = .overscan
      case "integer-scale": self = .integerScale
      default: self = .disabled
    }
  }
  
  public var defaultValueDescription: String {
    switch self {
      case .stretch: return "stretch"
      case .letterbox: return "letterbox"
      case .overscan: return "overscan"
      case .integerScale: return "integer-scale"
      default: return "disabled"
    }
  }
  
  public static var allValueStrings: [String] {
    [
      "disabled",
      "stretch",
      "letterbox",
      "overscan",
      "integer-scale"
    ]
  }
}

extension Window {
  internal func sync(options: GameOptions) throws(SDL_Error) {
    if let windowTitle    = options.windowTitle { try set(title: windowTitle) }
    if let windowMinSize  = options.windowMinSize { try set(minSize: windowMinSize) }
    if let windowMaxSize  = options.windowMaxSize { try set(maxSize: windowMaxSize) }
    if let windowSize     = options.windowSize { try set(size: windowSize) }
    if let windowPosition = options.windowPosition { try set(position: windowPosition) }
    
    /// These `has` checks ensure that flags which have already been set by the `Game` instance are overwritten.
    if !has(.always_on_top) { try set(alwaysOnTop: options.windowAlwaysOnTop) }
    if !has(.mouse_focus) { try set(mouseFocus: options.windowMouseFocus) }
    if !has(.resizable)  { try set(resizable: options.windowResizable) }
    if !has(.borderless) { try set(showBorder: !options.windowNoFrame) }
    if !has(.minimized) && options.windowMinimized { try self(SDL_MinimizeWindow) }
    if !has(.maximized) && options.windowMaximized { try self(SDL_MaximizeWindow) }
    
    _ = options.hideCursor ? SDL_HideCursor() : SDL_ShowCursor()
    
    if let renderer = try? renderer.get() {
      print("Attempting to set vsync to \"\(options.vsync)\"")
      try renderer.set(vsync: options.vsync.rawValue)
      
      let existingLogicalSize = SDL_Size(try renderer.logicalSize.get())
      var logicalSize         = options.logicalSize ?? existingLogicalSize
      let logicalPresentation = options.autoScaleContent ? .stretch : options.logicalPresentation
      
      // Mirrors 'logicalSize' to `window.size` when empty...
      if logicalSize.x == 0, logicalSize.y == 0 {
        logicalSize = SDL_Size(try self.size(as: Int32.self))
      }
      
      print("Attempting to set logical size to: \(logicalSize.x)x\(logicalSize.y) -- \(logicalPresentation)")
      try renderer.set(logicalSize: [logicalSize.x, logicalSize.y], presentation: logicalPresentation)
    }
    
    try self(SDL_SyncWindow)
  }
}
