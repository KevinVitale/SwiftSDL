public protocol Game: AnyObject, ParsableCommand {
  static var name: String { get }
  static var version: String { get }
  static var identifier: String { get }
  
  static var windowFlags: [SDL_WindowCreateFlag] { get }
  
  func onInit() throws(SDL_Error) -> any Window
  func onReady(window: any Window) throws(SDL_Error)
  func onUpdate(window: any Window, _ delta: Uint64) throws(SDL_Error)
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error)
  func onShutdown(window: any Window) throws(SDL_Error)
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
  
  public static var windowFlags: [SDL_WindowCreateFlag] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640)
    ]
  }
  
  public var gameControllers: [GameController] {
    GameControllers
  }
  
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(.video)
    
    let window = try SDL_CreateWindow(with: Self.windowFlags)
    let _ = try window.size(as: Float.self)
    
    return window
  }
  
  public func onQuit(_ result: SDL_Error?) {
    SDL_Quit()
  }
  
  public func did(connect gameController: inout GameController) throws(SDL_Error) { /* no-op */ }
  public func will(remove gameController: GameController) { /* no-op */ }
}

extension Game {
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
}

public protocol GameDelegate: AnyObject {
}
