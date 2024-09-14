@main
public final class MyGame: Game {
  public init() { }
  
  public static func main() async throws {
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "Portrait")
    
    SDL_RunApp(CommandLine.argc, CommandLine.unsafeArgv, { argc, argv in
      do { try App.run(MyGame.self) }
      catch { return -1 }
      return 0
    }, nil)
  }

  public static var name: String { "" }
  public static var version: String { "" }
  public static var identifier: String { "" }
  
  private var scene: CameraScene!


  public func onReady(window: any Window) throws(SDL_Error) {
    try SDL_Init(.camera)
    
    let size = try window.size(as: Float.self)
    scene = try CameraScene(size: size) { camera, _, _ in
      true
    }

  }
  
  public func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
    try scene.update(window: window, at: delta)
  }
  
  public func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    scene.size = try window.size(as: Float.self)
  }
  
  public func onShutdown(window: any Window) throws(SDL_Error) {
    scene.camera?.destroy()
  }
}

