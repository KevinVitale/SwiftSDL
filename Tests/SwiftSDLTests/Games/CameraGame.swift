import SwiftSDL

final class CameraGame: Game {
  static var name: String = "Camera App"
  static var version: String = ""
  static var identifier: String = ""
  
  private var scene: CameraScene!
  
  init() {
    #if os(Linux)
    print("Framebuffer acceleration:", SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, "1"))
    #endif
    print("Vsync:", SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1"))
  }
  
  func onReady(window: any Window) throws(SDL_Error) {
    try SDL_Init(.camera)
    
    #if os(Linux)
    print("Create renderer:", try window.get(SDL_CreateRenderer, nil))
    #else
    #endif

    let size = try window.size(as: Float.self)
    scene = try CameraScene(size: size) { camera, _, _ in
      return camera.name.contains("FaceTime")
    }
  }
  
  func onUpdate(window: any Window, _ delta: Tick) throws(SDL_Error) {
    try scene.update(window: window, at: delta)
  }
  
  func onEvent(window: any Window, _ event: SDL_Event) throws(SDL_Error) {
    switch event.eventType {
      case .keyDown: ()
        switch event.key {
          case SDLK_SPACE: ()
            scene.bgColor = .random
          default: ()
        }
      case .mouseMove: ()
      default: ()
    }
  }
  
  func onShutdown(window: any Window) throws(SDL_Error) {
    scene.camera?.destroy()
  }
}
