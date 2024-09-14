@MainActor
public protocol Game: AnyObject {
  init ()
  
  static var name: String { get }
  static var version: String { get }
  static var identifier: String { get }
  
  static var windowFlags: [SDL_WindowCreateFlag] { get }

  func onInit() throws(SDL_Error) -> any Window
  func onReady(window: any Window) throws(SDL_Error)
  func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error)
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error)
  func onShutdown(window: any Window) throws(SDL_Error)
  func onQuit(_ result: SDL_Error?)
}

extension Game {
  @MainActor
  public static func main() async throws {
    try App.run(Self.self)
  }
  
  @MainActor
  public static var windowFlags: [SDL_WindowCreateFlag] {
    [
      .windowTitle("\(Self.name)"),
      .width(1024), .height(640)
    ]
  }

  @MainActor
  public func onInit() throws(SDL_Error) -> any Window {
    try SDL_Init(.video)
    
    let window = try SDL_CreateWindowWithProperties(Self.windowFlags)
    let _ = try window.size(as: Float.self)
    
    return window
  }

  @MainActor
  public func onQuit(_ result: SDL_Error?) {
    SDL_Quit()
  }
}
