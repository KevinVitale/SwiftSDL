import SwiftSDL

final class TestGame: Game {
  fileprivate typealias Scene = TestScene
  
  static var name: String = "Test Game"
  static var version: String = ""
  static var identifier: String = ""
  
  private var scene: Scene!
  
  func onReady(window: any Window) throws(SDL_Error) {
    /*
    IMG_Init(.png)
    TTF_Init()
     */
    
    scene = .init(size: try window.size(as: Float.self))
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
    /*
    TTF_Quit()
    IMG_Quit()
     */
  }
}

fileprivate final class TestScene: BaseScene {
  override func update(window: any Window, at delta: Tick) throws(SDL_Error) {
    try _draw(try window.surface.get())
    try window.updateSurface()
  }
  
  @MainActor private func _draw(_ surface: any Surface) throws(SDL_Error) {
    try surface.clear(color: bgColor)
  }
}
