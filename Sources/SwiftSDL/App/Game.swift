public protocol Game: AnyObject, AsyncParsableCommand {
  /// A game's window's title can be automatically set using this `name` value.
  static var name: String { get }
  static var version: String { get }
  static var identifier: String { get }
  
  static var windowFlags: [SDL_WindowCreateFlag] { get }
  static var initFlags: [Flags.InitSDL] { get }
  
  @MainActor
  func onInit() throws(SDL_Error) -> any Window
  
  @MainActor
  func onReady(window: any Window) throws(SDL_Error)
  
  @MainActor
  func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error)
  
  @MainActor
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error)
  
  @MainActor
  func onShutdown(window: any Window) throws(SDL_Error)
  
  @MainActor
  func onQuit(_ result: SDL_Error?)
}

extension Game {
  public static var name: String { "\(Self.self)" }
  public static var version: String { "" }
  public static var identifier: String { "" }
  
  public static var windowFlags: [SDL_WindowCreateFlag] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640)
    ]
  }
  
  public static var initFlags: [Flags.InitSDL] {
    [
      .video,
      .joystick,
      .gamepad
    ]
  }
}

extension Game {
  @MainActor
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(Self.initFlags)
    
    let window = try SDL_CreateWindow(with: Self.windowFlags)
    let _ = try window.size(as: Float.self)
    
    return window
  }
  
  @MainActor
  public func onQuit(_ result: SDL_Error?) {
    /*
     defer {
     #if DEBUG
     if result != nil {
     print(SDL_Error.callStackDescription)
     }
     #endif
     }
     */
    SDL_Quit()
  }
}

extension Game {
  @MainActor public func run() async throws {
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
            try GameControllers.shared.handle(event)
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
        App.game.onQuit(error)
      })
      
      return 0
    }, nil)
  }
}
