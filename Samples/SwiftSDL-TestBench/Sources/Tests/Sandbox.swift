extension SDL.Test {
  // final class Sandbox: Game {
  final class Sandbox: Game {
    enum CodingKeys: CodingKey {
      case options
    }
    
    @OptionGroup var options: Options
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      var num_keyboards: Int32 = 0
      var num_mice: Int32 = 0;
      var num_joysticks: Int32 = 0;
      var joystick: OpaquePointer? = nil
      var instance: SDL_JoystickID = 0
      var keepGoing = true
      
      SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
      
      SDL_free(SDL_GetKeyboards(&num_keyboards));
      print("Keyboards:", num_keyboards)
      
      SDL_free(SDL_GetMice(&num_mice));
      print("Mice:", num_mice)
      
      SDL_free(SDL_GetJoysticks(&num_joysticks));
      print("Joysticks:", num_joysticks)
      
      while keepGoing {
        var event = SDL_Event()
        while (SDL_PollEvent(&event)) {
          switch event.eventType {
            case SDL_EVENT_QUIT:
              keepGoing = false;
              break;
            case SDL_EVENT_KEYBOARD_ADDED:
              print(event.eventType)
              break;
            case SDL_EVENT_KEYBOARD_REMOVED:
              print(event.eventType)
              break;
            case SDL_EVENT_MOUSE_ADDED:
              print(event.eventType)
              break;
            case SDL_EVENT_MOUSE_REMOVED:
              print(event.eventType)
              break;
              
            case SDL_EVENT_JOYSTICK_ADDED:
              if (joystick != nil) {
                print("Only one joystick supported by this test\n");
              } else {
                joystick = SDL_OpenJoystick(event.jdevice.which);
                instance = event.jdevice.which;
                print("Joy Added  : \(event.jdevice.which) : \(String(cString: SDL_GetJoystickName(joystick)))\n")
              }
              
            case SDL_EVENT_JOYSTICK_REMOVED:
              if (instance == event.jdevice.which) {
                print("Joy Removed: \(event.jdevice.which)\n")
                instance = 0;
                SDL_CloseJoystick(joystick);
                joystick = nil;
              } else {
                print("Unknown joystick disconnected\n");
              }
            default: ()
          }
        }
      }
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
    }
  }
}
