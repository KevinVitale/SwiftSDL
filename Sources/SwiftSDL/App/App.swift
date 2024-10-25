@MainActor final class App: Sendable {
  private init() { }
  
  static let shared = App()
  
  private var gameType: Game.Type!
  private var ticks = Tick(value: .infinity, unit: .nanoseconds)
  
  static func run(_ gameType: Game.Type) throws {
    shared.gameType = gameType
    
    guard SDL_SetAppMetadata(
      shared.gameType.name,
      shared.gameType.version,
      shared.gameType.identifier)
    else {
      throw SDL_Error.error
    }
    
    SDL_RunApp(CommandLine.argc, CommandLine.unsafeArgv, { argc, argv in
      App._startCallbacks(argc, argv)
      return 0
    }, nil)
  }
  
  private static func _startCallbacks(
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
  ) {
    SDL_EnterAppMainCallbacks(argc, argv, { state, argc, argv in
      /* onInit */
      do {
        let game = App.shared.gameType.init()
        let window = try game.onInit()
        
        let appState = State(game: AnyGame(game), window: AnyWindow(window))
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
        
        let appState = Unmanaged<State>.fromOpaque(state!).takeUnretainedValue()
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
        
        let appState = Unmanaged<State>.fromOpaque(state!).takeUnretainedValue()
        try appState.game.onEvent(window: appState.window, event)
        
        return .continue
      } catch {
        return .failure
      }
    }, /* onQuit */ { state, result in
      let error: SDL_Error? = (result == .failure ? .error : nil)
      if let error = error { debugPrint(error) }
      
      let appStatePtr = Unmanaged<State>.fromOpaque(state!)
      let window = appStatePtr.takeUnretainedValue().window
      let game = appStatePtr.takeUnretainedValue().game
      
      try? game.onShutdown(window: window)
      game.onQuit(error)
      
      appStatePtr.release() // destroys 'window'
    })
  }
}

public struct SDL_AppMetadataFlags: RawRepresentable, Sendable {
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public let rawValue: String
  
  public static let name = Self(rawValue: SDL_PROP_APP_METADATA_NAME_STRING)
  public static let version = Self(rawValue: SDL_PROP_APP_METADATA_VERSION_STRING)
  public static let identifier = Self(rawValue: SDL_PROP_APP_METADATA_IDENTIFIER_STRING)
  public static let creator = Self(rawValue: SDL_PROP_APP_METADATA_CREATOR_STRING)
  public static let copyright = Self(rawValue: SDL_PROP_APP_METADATA_COPYRIGHT_STRING)
  public static let url = Self(rawValue: SDL_PROP_APP_METADATA_URL_STRING)
  public static let type = Self(rawValue: SDL_PROP_APP_METADATA_TYPE_STRING)
}

extension SDL_AppResult: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let `continue` = SDL_APP_CONTINUE
  public static let success = SDL_APP_SUCCESS
  public static let failure = SDL_APP_FAILURE
  
  public static var allCases: [Self] {
    [
      .continue,
      .success,
      .failure
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .continue: return "continue"
      case .failure: return "failure"
      case .success: return "success"
      default: return "Unknown SDL_AppResult: \(self)"
    }
  }
}

public typealias Tick = Measurement<UnitDuration>

fileprivate struct AnyWindow {
  init(_ base: some Window) { self.base = base }
  let base: Any
}

fileprivate struct AnyGame {
  init(_ base: some Game) { self.base = base }
  let base: Any
}

extension App {
  fileprivate final class State {
    fileprivate init(game: AnyGame, window: AnyWindow) {
      self._game = game
      self._window = window
    }
    
    deinit {
      window.destroy()
    }
    
    private let _game: AnyGame
    private let _window: AnyWindow
    
    var game: any Game { _game.base as! (any Game) }
    var window: any Window { _window.base as! (any Window) }
  }
}
