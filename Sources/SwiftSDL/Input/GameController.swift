final class GameControllers: Sendable {
  private init() { }
  
  static let shared = GameControllers()
  
  @MainActor private var game: (any Game) { App.game }

  func handle(_ event: SDL_Event) throws(SDL_Error) {
    let joystickID = event.jdevice.which
    switch event.eventType {
      case .joystickAdded: try self.add(joystickID)
      case .joystickRemoved:
        let joysticks = try SDL_ConnectedJoystickIDs()
        if joysticks.first(where: { $0 == joystickID }) != nil {
          print("Joystick \(joystickID) removed")
        }
      default: ()
    }
  }
  
  private func add(_ joystickID: SDL_JoystickID) throws(SDL_Error) {
    if SDL_GetJoystickFromID(joystickID) == nil {
      print("Opening \(SDL_IsGamepad(joystickID) ? "#\(joystickID) gamepad..." : "#\(joystickID) joystick...")")
      let OpenFunc = SDL_IsGamepad(joystickID) ? SDL_OpenGamepad : SDL_OpenJoystick
      let pointer = OpenFunc(joystickID)
      
      if let joystickName = SDL_GetJoystickName(pointer) {
        print("Joystick Name: \(String(cString: joystickName))")
      }
      
      if let gamepadName = SDL_GetGamepadName(pointer) {
        print("Gamepad Name: \(String(cString: gamepadName))")
      }
      
      var touchDevices: Int32 = 0
      let ptr = SDL_GetTouchDevices(&touchDevices)
      print("Touch Devices:", touchDevices)
      SDL_free(ptr)
      
      for sensor in SDL_SensorType.allCases {
        let hasSensor = SDL_GamepadHasSensor(pointer, sensor)
        print("Sensor: \(sensor), \(sensor.rawValue), \(hasSensor)")
        if hasSensor {
          print("  Enabled \(sensor) at ".appendingFormat("%.2f", SDL_GetGamepadSensorDataRate(pointer, sensor)))
          SDL_SetGamepadSensorEnabled(pointer, sensor, true)
        }
      }
      
      if let mapping = SDL_GetGamepadMapping(pointer) {
        print("Mapping: \(String(cString: mapping))")
        SDL_free(mapping)
      }
    }
    else {
      print("Joystick \(joystickID) already exists")
    }
  }
}
