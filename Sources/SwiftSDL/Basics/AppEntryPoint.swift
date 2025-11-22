public typealias Game = GameLoop

public protocol GameLoop: AnyObject, ParsableCommand, SDL_PropertyTypeValue {
  /// The name of the application (“My Game 2: Bad Guy’s Revenge!”).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_NAME_STRING_.
  static var name: String { get }
  
  /// The version of the application (“1.0.0beta5” or a git hash, or whatever makes sense).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_VERSION_STRING_.
  static var version: String { get }
  
  /// A unique string in reverse-domain format that identifies this app (“com.example.mygame2”).
  /// - seealso: _SDL_SetAppMetadata_; _SDL_PROP_APP_METADATA_IDENTIFIER_STRING_.
  static var identifier: String { get }
  
  /// The default window properties for creating the main window.
  static var windowProperties: [SDL_WindowProperty] { get }
  
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
  func onInit() throws(SDL_Error) -> (any Window)
  
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
   
   For example, this how the `Geometry` test bench  implements its `onUpdate(window:`:
   
   ```
   func onUpdate(window: any Window) throws(SDL_Error) {
   try renderer
       .clear(color: .gray)
       .set(blendMode: blendMode)
       .pass(to: _drawGeometry(_:))
       .present()
   }
   ```
   
   - seealso: _SDL_AppIterate_
   */
  func onUpdate(window: any Window) throws(SDL_Error)
  
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
  
  /// Time since the last frame (in seconds).
  @available(*, deprecated)
  var deltaTime: Double { get }
}

private final class GameLoopFailure: SDL_PropertyTypeValue, Sendable {
  enum CallbackState: String {
    case onInit
    case onIterate
    case onEvent
    case none
  }
  let error: SDL_Error
  let state: CallbackState
  
  init(error: SDL_Error, state: CallbackState) {
    self.error = error
    self.state = state
  }
}

fileprivate let __gameLoopInstanceString = "SDL.kit.global.gameLoop.instance"
fileprivate let __gameLoopFailureString = "SDL.kit.global.gameLoop.failure"
fileprivate let __gameWindowString = "SDL.kit.global.gameLoop.window"

fileprivate func __SetGlobalProperty(_ property: String, to value: (any SDL_PropertyTypeValue)) throws(SDL_Error) {
  try SDL_PropertiesID.global()[property] = value
}

fileprivate func __GetGameLoop() throws(SDL_Error) -> (any GameLoop) {
  let gamePtr = try SDL_PropertiesID.global()[__gameLoopInstanceString] as! UnsafeMutableRawPointer
  let gameLoop = (Unmanaged<AnyObject>.fromOpaque(gamePtr).takeUnretainedValue()) as! (any GameLoop)
  return gameLoop
}

fileprivate func __GetGameLoopFailure() throws(SDL_Error) -> GameLoopFailure? {
  guard let failurePtr = try SDL_PropertiesID.global()[__gameLoopFailureString] as? UnsafeMutableRawPointer
  else { return nil }
  
  let gameLoopFailure = (Unmanaged<GameLoopFailure>.fromOpaque(failurePtr).takeUnretainedValue())
  return gameLoopFailure
}

fileprivate func __GetGameWindow() throws(SDL_Error) -> (any Window) {
  let winPtr = try SDL_PropertiesID.global()[__gameWindowString] as! UnsafeMutableRawPointer
  let window = (Unmanaged<AnyObject>.fromOpaque(winPtr).takeUnretainedValue()) as! (any Window)
  return window
}

final class __GameLoopInterval {
  private(set) var tick: Double
  private(set) var delta: Double
  
  private init(tick: Double = .nan, delta: Double = .nan) {
    self.tick = tick
    self.delta = delta
  }
  
  nonisolated(unsafe) static fileprivate let shared = __GameLoopInterval()
  
  // https://gist.github.com/xeekworx/4ed45c039ea1676ddef1c2d9f921973d
  func iterate(at now: Double = Double(SDL_GetPerformanceCounter()) / Double(SDL_GetPerformanceFrequency())) {
    var previous = tick
    
    if previous.isNaN {
      previous = now
    }
    
    delta = now - previous
    tick = now
  }
}

extension GameLoop {
  public static var name: String { "\(Self.self)" }
  public static var version: String { "" }
  public static var identifier: String { "" }
  public static var windowProperties: [SDL_WindowProperty] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640),
    ]
  }
}

extension GameLoop {
  public func onInit() throws(SDL_Error) -> (any Window) {
    try SDL_Init(.video)
    
    var windowProperties = Self.windowProperties
    windowProperties.append(.transparent(options.windowTransparent))
    
    return try SDL_Object(with: windowProperties)
  }

  public func onQuit(_ result: SDL_Error?) {
    SDL_Quit()
  }
}

extension GameLoop {
  public func run() throws {
    try SDL_AppMetadata.set(to: Self.self)
    try __SetGlobalProperty(__gameLoopInstanceString, to: self)

    SDL_RunApp(CommandLine.argc, CommandLine.unsafeArgv, { argc, argv in
      SDL_EnterAppMainCallbacks(argc, argv, { state, argc, argv in
        /* onInit */
        do {
          // Get 'this' instance and create a 'window' for it.
          // Store the 'window' to 'globalProperties' (persists for the life-time of the app).
          // The 'window' will automatically be cleaned up ('desroyed') during SDL_Quit().
          let gameLoop = try __GetGameLoop()
          let gameWindow = try gameLoop.onInit()
          try __SetGlobalProperty(__gameWindowString, to: gameWindow)

          // Inform the caller that its ready to perform additional setup.
          try gameLoop.onReady(window: gameWindow)
          
          // Sync runtime and compile-time game options.
          try gameWindow.sync(options: gameLoop.options)

          return .continue
        } catch {
          let gameLoopFailure = GameLoopFailure(error: error as! SDL_Error, state: .onInit)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onIterate */ { state in
        do {
          let gameLoop = try __GetGameLoop()
          let gameWindow = try __GetGameWindow()
          
          __GameLoopInterval.shared.iterate()
          try gameLoop.onUpdate(window: gameWindow)

          return .continue
        } catch {
          let gameLoopFailure = GameLoopFailure(error: error as! SDL_Error, state: .onIterate)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onEvent */ { state, event in
        guard let event = event?.pointee else {
          return .failure
        }
        
        do {
          
          let gameLoop = try __GetGameLoop()
          let gameWindow = try __GetGameWindow()

          guard event.type != SDL_EventType.quit.rawValue else {
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
                        try gameLoop.did(connect: &gameController)
                        
                      case .remove(_, var gameController, _):
                        gameLoop.will(remove: gameController)
                        gameController.close()
                    }
                  }
                
              default: ()
            }
          }
          
          try gameLoop.onEvent(window: gameWindow, event)
          return .continue
        } catch {
          let gameLoopFailure = GameLoopFailure(error: error as! SDL_Error, state: .onEvent)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onQuit */ { state, result in
        let failure = try? __GetGameLoopFailure()
        switch failure {
          case .none: break
          case .some(let failure): debugPrint(failure)
        }
        
        let gameLoop = try? __GetGameLoop()
        let gameWindow = try? __GetGameWindow()
        
        try? gameLoop?.onShutdown(window: gameWindow)
        
        for var gameController in GameControllers {
          gameController.close()
        }
        GameControllers = []
        
        gameLoop?.onQuit(failure?.error)
      })
      
      return 0
    }, nil)
  }
}

nonisolated(unsafe)
internal var GameControllers: [GameController] = []

extension Game {
  
  public var gameControllers: [GameController] {
    GameControllers
  }
  
  public var deltaTime: Double {
    __GameLoopInterval.shared.delta
  }
  
  /// Get the global SDL properties.
  /// - returns: Either global properties, or a _SDL_Error_ failure.
  /// - seealso: _SDL_GetGlobalProperties_
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    fatalError()
  }
  
  /// Set a property in the global properties group.
  /// - parameters:
  ///   - property: The property to modify.
  ///   - value: The new value of the property.
  /// - returns: The _SDL_PropertiesID_ for the group being modified.
  /// - seealso: _SDL_SetStringProperty_; _SDL_SetFloatProperty_; _SDL_SetBooleanProperty_; _SDL_SetNumberProperty_; _SDL_SetPointerProperty_.
  @discardableResult
  public func set<P: SDL_PropertyTypeValue>(property: String, value: P) throws(SDL_Error) -> SDL_PropertiesID {
    fatalError()
  }
  
  public func did(connect gameController: inout GameController) throws(SDL_Error) { /* no-op */ }
  public func will(remove gameController: GameController) { /* no-op */ }
}

public struct SDL_AppMetadata: Sendable {
  public enum CodingKeys: String, CodingKey {
    case name
    case version
    case identifier
    case creator
    case copyright
    case url
    case type
    
    public var stringValue: String {
      switch self {
        case .name: return SDL_PROP_APP_METADATA_NAME_STRING
        case .version: return SDL_PROP_APP_METADATA_VERSION_STRING
        case .identifier: return SDL_PROP_APP_METADATA_IDENTIFIER_STRING
        case .creator: return SDL_PROP_APP_METADATA_CREATOR_STRING
        case .copyright: return SDL_PROP_APP_METADATA_COPYRIGHT_STRING
        case .url: return SDL_PROP_APP_METADATA_URL_STRING
        case .type: return SDL_PROP_APP_METADATA_TYPE_STRING
      }
    }
  }
  
  private init() { }
  
  fileprivate static func set<T: GameLoop>(to gameLoop: T.Type) throws(SDL_Error) {
    guard SDL_SetAppMetadata(
      T.name,
      T.version,
      T.identifier)
    else {
      throw SDL_Error.error
    }
  }
  
  public static subscript(property: CodingKeys) -> String {
    get {
      String(cString: SDL_GetAppMetadataProperty(property.stringValue))
    }
    set {
      if !SDL_SetAppMetadataProperty(property.stringValue, newValue) {
        debugPrint(SDL_Error.error)
      }
    }
  }
}

public enum SDL_InitFlags: UInt32, CaseIterable, ExpressibleByIntegerLiteral, OptionSet {
  public init(integerLiteral value: UInt32) {
    self.init(rawValue: value)
  }
  
  public init(rawValue: Uint32) {
    switch rawValue {
      case SDL_INIT_AUDIO:    self = .audio
      case SDL_INIT_VIDEO:    self = .video
      case SDL_INIT_JOYSTICK: self = .joystick
      case SDL_INIT_HAPTIC:   self = .haptic
      case SDL_INIT_GAMEPAD:  self = .gamepad
      case SDL_INIT_EVENTS:   self = .events
      case SDL_INIT_SENSOR:   self = .sensor
      case SDL_INIT_CAMERA:   self = .camera
      default: self = .invalid
    }
  }
  
  case audio
  case video
  case joystick
  case haptic
  case gamepad
  case events
  case sensor
  case camera
  case invalid
  
  public var debugDescription: String {
    switch self {
      case .audio:    return "audio"
      case .video:    return "video"
      case .joystick: return "joystick"
      case .haptic:   return "haptic"
      case .gamepad:  return "gamepad"
      case .events:   return "events"
      case .sensor:   return "sensor"
      case .camera:   return "camera"
      case .invalid:  return "invalid"
    }
  }
  
  public var rawValue: UInt32 {
    switch self {
      case .audio: return SDL_INIT_AUDIO
      case .video: return SDL_INIT_VIDEO
      case .joystick: return SDL_INIT_JOYSTICK
      case .haptic: return SDL_INIT_HAPTIC
      case .gamepad: return SDL_INIT_GAMEPAD
      case .events: return SDL_INIT_EVENTS
      case .sensor: return SDL_INIT_SENSOR
      case .camera: return SDL_INIT_CAMERA
      case .invalid: return 0
    }
  }
  
  public static var allCases: [Self] {
    [
      .audio,
      .video,
      .joystick,
      .haptic,
      .gamepad,
      .events,
      .sensor,
      .camera
    ]
  }
}

public func SDL_Init(_ flags: SDL_InitFlags...) throws(SDL_Error) {
  try SDL_Init(flags)
}

public func SDL_Init(_ flags: [SDL_InitFlags]) throws(SDL_Error) {
  guard SDL_Init(flags.reduce(0) { $0 | $1.rawValue }) else {
    throw .error
  }
}

