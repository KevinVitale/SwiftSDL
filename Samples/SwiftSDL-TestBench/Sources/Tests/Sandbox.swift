extension SDL.Test {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey {
      case options
    }
    
    @OptionGroup var options: Options
    
    private var renderer: OpaquePointer!
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
      SDL_SetHint(SDL_HINT_POLL_SENTINEL, "1")
      SDL_SetHint(SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS, "1")
      
      renderer = try window.createRenderer().pointer
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      SDL_RenderClear(renderer)
      SDL_RenderPresent(renderer)
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      SDL_DestroyRenderer(renderer)
    }
  }
}
