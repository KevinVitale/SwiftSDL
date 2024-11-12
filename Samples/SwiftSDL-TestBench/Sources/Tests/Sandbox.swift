extension SDL.Test {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey {
      case options
    }
    
    @OptionGroup var options: Options
    
    private var renderer: (any Renderer)!
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      /* Enable input debug logging */
      SDL_SetLogPriority(Int32(SDL_LOG_CATEGORY_INPUT.rawValue), SDL_LOG_PRIORITY_DEBUG);
      
      _applyHints()
      renderer = try window.createRenderer()
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      SDL_Delay(16)
      try renderer
        .clear(color: .white)
        .present()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      switch event.eventType {
        case .gamepadAdded: ()
          print("gamepad added")
        case .gamepadRemoved: ()
          print("gamepad removed")
        default: ()
      }
    }
    
    func onShutdown(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      renderer = nil
    }
    
    private func _applyHints() {
      #if os(macOS)
      // Wired 360 controller wasn't reported...related?
      // See this issue: https://github.com/libsdl-org/SDL/issues/11002
      SDL_SetHint(SDL_HINT_JOYSTICK_MFI, "0")
      #endif
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS4_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_PS5_RUMBLE, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_HIDAPI_STEAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ROG_CHAKRAM, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
      SDL_SetHint(SDL_HINT_JOYSTICK_LINUX_DEADZONES, "1");
      
      SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
      SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1")
      SDL_SetHint(SDL_HINT_POLL_SENTINEL, "1")
      SDL_SetHint(SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS, "1")
    }
  }
}
