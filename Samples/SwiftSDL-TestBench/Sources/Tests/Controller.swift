extension SDL.Test {
  final class Controller: Game {
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL controller routines"
    )
    
    static let name: String = "SDL Test: Controller"
    
    func onReady(window: any Window) throws(SDL_Error) { }
    func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) { }
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) { }
    func onShutdown(window: any Window) throws(SDL_Error) { }
  }
}
