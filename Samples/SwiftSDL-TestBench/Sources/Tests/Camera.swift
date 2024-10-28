extension SDL.Test {
  final class Camera: Game {
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL camera routines"
    )
    
    static let name: String = "SDL Test: Camera"
    
    private var camera: CameraID! = nil
    
    func onReady(window: any Window) throws(SDL_Error) {
      try SDL_Init(.camera)
      
      camera = try Cameras.matching { _, _, _ in true }
    }
    
    func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
      let surface = try window.surface.get()
      try surface.clear(color: .gray)
      
      try camera.draw(to: surface)
      try window.updateSurface()
    }
    
    func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    }
    
    func onShutdown(window: any Window) throws(SDL_Error) {
      camera.close()
    }
  }
}
