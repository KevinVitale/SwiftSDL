
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
  
  /** Runtime options that customize a game's behavior and presentation.
   
   These options get applied **immediately after**  `onReady(window:)` completes.
   
   Those options which correspond to flags used when creating the `window` are ignored if
   they were already defined in `windowProperties` at compile time.

   - seealso: _GameOptions_
   */
  var options: GameOptions { get }
  
  /**
   Called once to initialize SDL and create the game's main window.
   
   - note: A default implementation is provided which automatically initializes SDL's _video_ subsystem,
   and creates the `window` based on `windowProperties`.

   The default implementation automatically:
   1. Initializes SDL's video subsystem.
   2. Creates a window using the properties specified in `windowProperties`.
   
   If this method throws an error:
   1. `onShutdown(window_:)` will be invoked to handle cleanup and unwind any partially initialized state.
   2. Following that, `onQuit(_:)` will be called, terminating the application with an appropriate exit code.

   - returns: Main window, created by calling `SDL_CreateWindow(with:)`.
   
   - warning: If you override this function, you must manually create the window
   and initialize any required SDL subsystems yourself. Overriding introduces significant responsibility and complexity; use caution.
   */
  func onInit() throws(SDL_Error) -> any Window
  
  /**
   Called **immediately after** the application's `window` is created and ready. After this function
   returns, the game's event-loop is started.
   
   Use `onReady(window:)`to perform one-time startup operations, such as:
   - initializing additional SDL subsytems (`joystick`, `audio`, etc.); or,
   - creating the window's accelerated _renderer_; and,
   - setting default game state; and,
   - loading initial assets or other required content.
   
   - parameter window: The `window` created by `onInit()`.
   */
  func onReady(window: any Window) throws(SDL_Error)
  
  /**
   Called over and over, possibly at the refresh rate of the display or some other metric that the platform dictates.
   
   This function should return as quickly as reasonably possible, during which,
   your game should update state, and render a frame of video.
   
   For example, this how the `Geometry` test bench  implements its `onUpdate(window:, _:`:
   
   ```
   func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error) {
     try renderer
       .clear(color: .gray)
       .set(blendMode: blendMode)
       .pass(to: _drawGeometry(_:))
       .present()
   }
   ```
   
   - seealso: _SDL_AppIterate_
   */
  func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error)
  
  /**
   Called whenever an SDL event arrives.
   
   - note: Your app should not call SDL_PollEvent, SDL_PumpEvent, etc, as SDL will manage all this for you.
   
   - seealso: _SDL_AppEvent_
   */
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error)
  
  /**
   Called **immediately before** the application quits.
   
   Use this method to clean up resources such as game assets or memory allocations
   that were previously created or retained.
   
   - parameter window: the main `window`, or `nil` if it couldn't be created.

   - note: This function is **always called** whether or not the game initialized successfully.
   The `window` property may be `nil` if the application was unable to create it due to an initialization failure.
   */
  func onShutdown(window: (any Window)?) throws(SDL_Error)
  
  /**
   This method is called once during the application shutdown process as a last chance to clean up.
   
   Use  `onShutdown(window:)` rather than overriding `onQuit(_:)`. Otherwise,
   you're responsible for shutting down SDL's subsytem.
   
   - parameter result: An optional `SDL_Error` that indicates whether an error occurred
   prior to the process quitting.

   - warning: Implementing this method **overrides** the default implementation.
   The default implementation will automatically call `SDL_Quit` to shut down SDL's subsystems.
   
   - seealso: _SDL_AppQuit_
   */
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
          App.failure = .onInit(error as? SDL_Error)
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
          App.failure = .onIterate(error as? SDL_Error)
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
          App.failure = .onEvent(error as? SDL_Error)
          return .failure
        }
      }, /* onQuit */ { state, result in
        switch App.failure {
          case .noFailure: break
          default: print(App.failure)
        }
        
        defer { App.window = nil }
        try? App.game.onShutdown(window: App.window)
        
        for var gameController in GameControllers {
          gameController.close()
        }
        GameControllers = []
        
        App.game.onQuit(App.failure.error)
      })
      
      return 0
    }, nil)
  }
  
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(.video)
    
    var windowProperties = Self.windowProperties
    windowProperties.append(.transparent(options.windowTransparent))
    
    return try SDL_CreateWindow(with: windowProperties)
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
      throw .error
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
  public var renderLogicalSize: SDL_Size? = nil
  
  @Option(help: "Forces the rendered content to be a certain logical order; overrides '--auto-scale-content'")
  public var renderLogicalPresentation: SDL_RendererLogicalPresentation = .disabled
  
  @Option(help: "Set vertical synchronization rate")
  public var renderVsync: VSyncRate = .disabled
  
  @Flag(help: "Window is always kept on top")
  public var windowAlwaysOnTop: Bool = false
  
  @Flag(help: "Window is set to fullscreen")
  public var windowFullscreen: Bool = false

  @Flag(help: "Window is uses a transparent buffer")
  public var windowTransparent: Bool = false

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
    // Must have 'resizable' before 'maximized'
    if !has(.resizable)  { try set(resizable: options.windowResizable) }
    
    if let windowMinSize  = options.windowMinSize { try set(minSize: windowMinSize) }
    if let windowMaxSize  = options.windowMaxSize { try set(maxSize: windowMaxSize) }
    if let windowPosition = options.windowPosition { try set(position: windowPosition) }
    if let windowSize     = options.windowSize { try set(size: windowSize) }
    if let windowTitle    = options.windowTitle { try set(title: windowTitle) }
    
    /// These `has` checks ensure that flags which have already been set by the `Game` instance are overwritten.
    if !has(.always_on_top) { try set(alwaysOnTop: options.windowAlwaysOnTop) }
    if !has(.minimized) && options.windowMinimized { try self(SDL_MinimizeWindow) }
    if !has(.maximized) && options.windowMaximized { try self(SDL_MaximizeWindow) }
    if !has(.mouse_focus) { try set(mouseFocus: options.windowMouseFocus) }
    if !has(.borderless) { try set(showBorder: !options.windowNoFrame) }
    if !has(.fullscreen) { try self(SDL_SetWindowFullscreen, options.windowFullscreen) }

    _ = options.hideCursor ? SDL_HideCursor() : SDL_ShowCursor()
    
    if let renderer = try? renderer.get() {
      if try renderer.vsync.get() == 0, options.renderVsync != .disabled {
        print("Attempting to set vsync to \"\(options.renderVsync)\"")
        try renderer.set(vsync: options.renderVsync.rawValue)
      }
      
      let existingLogicalSize = SDL_Size(try renderer.logicalSize.get())
      let existingLogicalPres = try renderer.logicalPresentation.get()
      
      var logicalSize         = options.renderLogicalSize ?? existingLogicalSize
      let logicalPresentation = options.autoScaleContent ? .stretch : (existingLogicalPres != .disabled ? existingLogicalPres : options.renderLogicalPresentation)

      // Mirrors 'logicalSize' to `window.size` when empty...
      if logicalSize.x == 0, logicalSize.y == 0 {
        logicalSize = try self.size(as: SDL_Size.self)
      }
      
      print("Attempting to set logical size to: \(logicalSize.x)x\(logicalSize.y); presentation: \(logicalPresentation)")
      try renderer.set(logicalSize: [logicalSize.x, logicalSize.y], presentation: logicalPresentation)
    }
    
    try self(SDL_SyncWindow)
  }
}
