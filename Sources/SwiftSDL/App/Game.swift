public protocol Game: AnyObject, AsyncParsableCommand {
  /// A game's window's title can be automatically set using this `name` value.
  static var name: String { get }
  static var version: String { get }
  static var identifier: String { get }
  
  static var windowFlags: [SDL_WindowCreateFlag] { get }

  @MainActor
  func onInit() throws(SDL_Error) -> any Window
  
  @MainActor
  func onReady(window: any Window) throws(SDL_Error)
  
  @MainActor
  func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error)
  
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
}

extension Game {
  @MainActor
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(.video)
    
    let window = try SDL_CreateWindowWithProperties(Self.windowFlags)
    let _ = try window.size(as: Float.self)
    
    return window
  }
  
  @MainActor
  public func onQuit(_ result: SDL_Error?) {
    defer {
    #if DEBUG
    if result != nil {
      print(SDL_Error.callStackDescription)
    }
    #endif
    }
    SDL_Quit()
  }
}

extension Game {
  @MainActor public func run() async throws {
    App.shared.game = AnyGame(self)
    
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
          let game = App.shared.game.base as! any Game
          let window = try game.onInit()
          
          let appState = App.State(game: App.shared.game, window: AnyWindow(window))
          state?.pointee = Unmanaged.passRetained(appState).toOpaque()
          
          try game.onReady(window: window)
          
          return .continue
        } catch {
          return .failure
        }
      }, /* onIterate */ { state in
        do {
          let ticks = Tick(value: Double(SDL_GetTicksNS()), unit: .nanoseconds)
          if App.shared.ticks.value == .infinity {
            App.shared.ticks = ticks
          }
          
          let delta = Tick(
            value: ticks.value - App.shared.ticks.value,
            unit: .nanoseconds
          )
          
          App.shared.ticks = ticks
          
          let appState = Unmanaged<App.State>.fromOpaque(state!).takeUnretainedValue()
          try appState.game.onUpdate(window: appState.window, delta)
          
          return .continue
        } catch {
          return .failure
        }
      }, /* onEvent */ { state, event in
        guard let event = event?.pointee else {
          return .failure
        }
        do {
          guard event.eventType != .quit else {
            return .success
          }
          
          let appState = Unmanaged<App.State>.fromOpaque(state!).takeUnretainedValue()
          try appState.game.onEvent(window: appState.window, event)
          
          return .continue
        } catch {
          return .failure
        }
      }, /* onQuit */ { state, result in
        let error: SDL_Error? = (result == .failure ? .error : nil)
        if let error = error { debugPrint(error) }
        
        let appStatePtr = Unmanaged<App.State>.fromOpaque(state!)
        let window = appStatePtr.takeUnretainedValue().window
        let game = appStatePtr.takeUnretainedValue().game
        
        try? game.onShutdown(window: window)
        game.onQuit(error)
        
        appStatePtr.release() // destroys 'window'
      })
      
      return 0
    }, nil)
  }
}
