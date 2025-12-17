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
  static var windowProperties: [SDL_WindowCreateProperty] { get }
  
  /** Runtime options that customize a game's behavior and presentation.
   
   These options get applied **immediately after**  `onReady(window:)` completes.
   
   Those options which correspond to flags used when creating the `window` are ignored if
   they were already defined in `windowProperties` at compile time.
   
   - seealso: _GameOptions_
   */
  var options: GameOptions { get }
  
  /**
   Called **immediately before** the application initializes (e.g., calls `SDL_Init)`.
   
   The default implementation does nothing. Use this to set hints, load configurations, or even initialize
   other non-_video_ SDL subsysytems.
   */
  func willInit() throws(SDL_Error)
  
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
   Use this method to clean up resources such as game assets or memory allocations
   that were previously created or retained.
   
   - parameter window: the main `window`, or `nil` if it couldn't be created.
   - parameter failure: indicates the error occurred if `window` is `nil` for some reason.
   prior to the process quitting.

   - note: This function is **always called** whether or not the game initialized successfully.
   The `window` property may be `nil` if the application was unable to create it (due to an some failure).
   When this happens, check `error` for what may have happened.
   */
  func onShutdown(window: (any Window)?, failure: GameLoopFailure)
  
  /**
   Called **immediately before** the application quits (e.g., calls `SDL_Quit)`.
   */
  func willQuit()
  
  func did(add gamepad: inout Gamepad) throws(SDL_Error)
  func did(remove connected: [Gamepad]) throws(SDL_Error)
  
  /// Time since the last frame (in seconds).
  @available(*, deprecated)
  var deltaTime: Double { get }
}

fileprivate let __gameLoopInstanceString = "SDL.kit.global.gameLoop.instance"
fileprivate let __gameLoopFailureString = "SDL.kit.global.gameLoop.failure"
fileprivate let __gameLoopStepString = "SDL.kit.global.gameLoop.step"
fileprivate let __gameWindowString = "SDL.kit.global.gameLoop.window"

fileprivate func __SetGlobalProperty(_ property: String, to value: (any SDL_PropertyTypeValue)) throws(SDL_Error) {
  try SDL_PropertiesID.global()[property] = value
}

fileprivate func __GetGameLoop() throws(SDL_Error) -> (any GameLoop) {
  let gamePtr = try SDL_PropertiesID.global()[__gameLoopInstanceString] as! UnsafeMutableRawPointer
  let gameLoop = (Unmanaged<AnyObject>.fromOpaque(gamePtr).takeUnretainedValue()) as! (any GameLoop)
  return gameLoop
}

fileprivate func __GetGameLoopFailure() throws(SDL_Error) -> __GameLoopFailure? {
  guard let failurePtr = try SDL_PropertiesID.global()[__gameLoopFailureString] as? UnsafeMutableRawPointer
  else { return nil }
  
  let gameLoopFailure = (Unmanaged<__GameLoopFailure>.fromOpaque(failurePtr).takeUnretainedValue())
  return gameLoopFailure
}

fileprivate func __GetGameWindow() throws(SDL_Error) -> (any Window) {
  let winPtr = try SDL_PropertiesID.global()[__gameWindowString] as! UnsafeMutableRawPointer
  let window = (Unmanaged<AnyObject>.fromOpaque(winPtr).takeUnretainedValue()) as! (any Window)
  return window
}

fileprivate func __GetGameLoopStep() throws(SDL_Error) -> GameLoopStep {
  guard let stepPtr = try SDL_PropertiesID.global()[__gameLoopStepString] as? UnsafeMutableRawPointer else {
    let step = GameLoopStep()
    try! __SetGameLoopStep(step)
    return step
  }
  let step = (Unmanaged<AnyObject>.fromOpaque(stepPtr).takeUnretainedValue()) as! GameLoopStep
  return step
}

fileprivate func __SetGameLoopStep(_ step: GameLoopStep = .init()) throws(SDL_Error) {
  (try SDL_PropertiesID.global())[__gameLoopStepString] = step
}

fileprivate final class GameLoopStep: SDL_PropertyTypeValue {
  private var previous: Double = .nan
  fileprivate(set) var delta: Double = .nan
  
  fileprivate func callAsFunction(at now: Double = Double(SDL_GetPerformanceCounter()) / Double(SDL_GetPerformanceFrequency())) throws(SDL_Error) {
    var previous = self.previous
    if previous.isNaN {
      previous = now
    }
    
    self.delta = now - previous
    self.previous = now
    
    try __SetGameLoopStep(self)
  }
}

extension GameLoop {
  public static var name: String { "\(Self.self)" }
  public static var version: String { "" }
  public static var libraryVersion: SDL_Version { .current }
  public static var identifier: String { "" }
  public static var windowProperties: [SDL_WindowCreateProperty] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640),
    ]
  }
  
  fileprivate var step: GameLoopStep { try! __GetGameLoopStep() }

  /**
   
   */
  public func willInit() throws(SDL_Error) { /*no-op*/ }
  
  /**
   
   */
  public func onInit() throws(SDL_Error) -> (any Window) {
    try willInit()
    try SDL_Init(.video, .joystick, .gamepad)
    
    var windowProperties = Self.windowProperties
    windowProperties.append(.transparent(options.windowTransparent))
    
    return try SDL_Object(with: windowProperties)
  }
  
  /**
   
   */
  public func willQuit() { /*no-op*/ }
}

extension GameLoop {
  public func run() throws {
    try SDL_AppMetadata.set(to: Self.self)
    try __SetGlobalProperty(__gameLoopInstanceString, to: self)

    SDL_RunApp(CommandLine.argc, CommandLine.unsafeArgv, { argc, argv in
      SDL_EnterAppMainCallbacks(argc, argv, { _, argc, argv in
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
          let gameLoopFailure = __GameLoopFailure(error: error as! SDL_Error, state: .onInit)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onIterate */ { _ in
        do {
          let gameLoop = try __GetGameLoop()
          let gameWindow = try __GetGameWindow()
          
          try gameLoop.step()
          try gameLoop.onUpdate(window: gameWindow)

          return .continue
        } catch {
          let gameLoopFailure = __GameLoopFailure(error: error as! SDL_Error, state: .onIterate)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onEvent */ { _, event in
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
              case .gamepadAdded:
                var gamepad = try Gamepad.locate(fromID: event.gdevice.which).get()
                try gameLoop.did(add: &gamepad)
              case .gamepadRemoved:
                let gamepads = try Gamepad.connected.get()
                try gameLoop.did(remove: gamepads)
              default: break
            }
          }

          try gameLoop.onEvent(window: gameWindow, event)
          
          return .continue
        } catch {
          let gameLoopFailure = __GameLoopFailure(error: error as! SDL_Error, state: .onEvent)
          (try? __SetGlobalProperty(__gameLoopFailureString, to: gameLoopFailure))
          return .failure
        }
      }, /* onQuit */ { _, result in
        let failure = try? __GetGameLoopFailure()
        let gameLoop = try? __GetGameLoop()
        let gameWindow = failure == nil ? try? __GetGameWindow() : nil
        
        switch failure {
          case .none: break
          case .some(let failure): SDL_Log(failure.error)
        }
        
        gameLoop?.onShutdown(
          window: gameWindow,
          failure: (failure?.gameLoopFailure ?? .none)
        )
        
        for var joystick in (try? Joystick.connected.get()) ?? [] {
          try? joystick.close()
        }

        gameLoop?.willQuit()
      })
      
      SDL_Quit()
      return 0
    }, nil)
  }
}

extension GameLoop {
  public var deltaTime: Double {
    (try? __GetGameLoopStep())?.delta ?? .nan
  }
  
  public func did(add gamepad: inout Gamepad) throws(SDL_Error) { /* no-op */ }
  public func did(remove connected: [Gamepad]) throws(SDL_Error) { /* no-op */ }
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
        SDL_Log(SDL_Error.error)
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

public func SDL_WasInit() -> [SDL_InitFlags] {
  let wasInit = __SDL_WasInit(0)
  return SDL_InitFlags.allCases.filter {
    return (wasInit & $0.rawValue) != 0
  }
}

public func SDL_WasInit(_ flags: SDL_InitFlags...) -> Bool {
  Set(SDL_WasInit()).intersection(Set(flags)).count == flags.count
}
