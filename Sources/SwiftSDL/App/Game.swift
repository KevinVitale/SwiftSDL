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
      .width(1024), .height(640)
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
    
    let window = try SDL_CreateWindow(with: Self.windowProperties)
    let _ = try window.size(as: Float.self)
    
    return window
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
