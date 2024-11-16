public func SDL_AttachVirtualJoystick(
  type: SDL_JoystickType,
  vendorID: UInt16 = .zero,
  productID: UInt16 = .zero,
  ballsCount: Int32 = .zero,
  hatsCount: Int32 = .zero,
  buttons: [SDL_GamepadButton] = SDL_GamepadButton.allCases,
  axises: [SDL_GamepadAxis] = SDL_GamepadAxis.allCases,
  name: String = "",
  touchpads: [SDL_VirtualJoystickTouchpadDesc] = [],
  sensors: [SDL_VirtualJoystickSensorDesc] = [],
  userdata: SDL_VirtualJoystickDesc.UserData.DataType = .init(),
  update: ((SDL_VirtualJoystickDesc.UserData.DataType) -> Void)? = nil,
  setPlayerIndex: ((SDL_VirtualJoystickDesc.UserData.DataType, Int32) -> Void)? = nil,
  rumble: ((SDL_VirtualJoystickDesc.UserData.DataType, Uint16, Uint16) -> Bool)? = nil,
  rumbleTriggers: ((SDL_VirtualJoystickDesc.UserData.DataType, Uint16, Uint16) -> Bool)? = nil,
  setLED: ((SDL_VirtualJoystickDesc.UserData.DataType, Uint8, Uint8, Uint8) -> Bool)? = nil,
  sendEffect: ((SDL_VirtualJoystickDesc.UserData.DataType, UnsafeRawPointer?, Int32) -> Bool)? = nil,
  setSensorsEnabled: ((SDL_VirtualJoystickDesc.UserData.DataType, Bool) -> Bool)? = nil,
  cleanup: ((SDL_VirtualJoystickDesc.UserData.DataType) -> Void)? = nil
) throws(SDL_Error) -> SDL_JoystickID {
  var desc = SDL_VirtualJoystickDesc(
    type: type,
    vendorID: vendorID,
    productID: productID,
    ballsCount: ballsCount,
    hatsCount: hatsCount,
    buttons: buttons,
    axises: axises,
    name: name,
    touchpads: touchpads,
    sensors: sensors,
    userdata: userdata,
    update: update,
    setPlayerIndex: setPlayerIndex,
    rumble: rumble,
    rumbleTriggers: rumbleTriggers,
    setLED: setLED,
    sendEffect: sendEffect,
    setSensorsEnabled: setSensorsEnabled,
    cleanup: cleanup
  )
  
  let virtualID = SDL_AttachVirtualJoystick(&desc)
  guard virtualID != .zero else {
    throw SDL_Error.error
  }
  
  return virtualID
}

extension SDL_JoystickType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let unknown = SDL_JOYSTICK_TYPE_UNKNOWN
  public static let gamepad = SDL_JOYSTICK_TYPE_GAMEPAD
  public static let wheel = SDL_JOYSTICK_TYPE_WHEEL
  public static let arcadeStick = SDL_JOYSTICK_TYPE_ARCADE_STICK
  public static let flightStick = SDL_JOYSTICK_TYPE_FLIGHT_STICK
  public static let dancePad = SDL_JOYSTICK_TYPE_DANCE_PAD
  public static let guitar = SDL_JOYSTICK_TYPE_GUITAR
  public static let drumKit = SDL_JOYSTICK_TYPE_DRUM_KIT
  public static let arcadePad = SDL_JOYSTICK_TYPE_ARCADE_PAD
  public static let throttle = SDL_JOYSTICK_TYPE_THROTTLE
  
  public var debugDescription: String {
    switch self {
      case SDL_JOYSTICK_TYPE_UNKNOWN: return "unknown"
      case SDL_JOYSTICK_TYPE_GAMEPAD: return "gamepad"
      case SDL_JOYSTICK_TYPE_WHEEL: return "wheel"
      case SDL_JOYSTICK_TYPE_ARCADE_STICK: return "arcade stick"
      case SDL_JOYSTICK_TYPE_FLIGHT_STICK: return "flight stick"
      case SDL_JOYSTICK_TYPE_DANCE_PAD: return "dance pad"
      case SDL_JOYSTICK_TYPE_GUITAR: return "guitar"
      case SDL_JOYSTICK_TYPE_DRUM_KIT: return "drum kit"
      case SDL_JOYSTICK_TYPE_ARCADE_PAD: return "arcade pad"
      case SDL_JOYSTICK_TYPE_THROTTLE: return "throttle"
      case SDL_JOYSTICK_TYPE_COUNT: return "\(SDL_JOYSTICK_TYPE_COUNT.rawValue)"
      default: return "Unknown SDL_JoystickType: \(self.rawValue)"
    }
  }
  public static var allCases: [SDL_JoystickType] {
    [
      SDL_JOYSTICK_TYPE_UNKNOWN,
      SDL_JOYSTICK_TYPE_GAMEPAD,
      SDL_JOYSTICK_TYPE_WHEEL,
      SDL_JOYSTICK_TYPE_ARCADE_STICK,
      SDL_JOYSTICK_TYPE_FLIGHT_STICK,
      SDL_JOYSTICK_TYPE_DANCE_PAD,
      SDL_JOYSTICK_TYPE_GUITAR,
      SDL_JOYSTICK_TYPE_DRUM_KIT,
      SDL_JOYSTICK_TYPE_ARCADE_PAD,
      SDL_JOYSTICK_TYPE_THROTTLE
    ]
  }
}

public func SDL_ConnectedJoystickIDs() throws(SDL_Error) -> [SDL_JoystickID] {
  try SDL_BufferPointer(SDL_GetJoysticks)
}

public enum GameController: Hashable {
  case connected(SDL_JoystickID)
  case open(OpaquePointer)
  case invalid
  
  public var id: SDL_JoystickID {
    switch self {
      case .invalid: return .zero
      case .connected(let id): return id
      case .open(let pointer): return SDL_GetJoystickID(pointer)
    }
  }
  
  public var isGamepad: Bool {
    SDL_IsGamepad(id)
  }
  
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var joystick: OpaquePointer? {
    guard case(.open) = self else {
      return nil
    }
    return SDL_GetJoystickFromID(id)
  }
  
  public var joystickName: String {
    guard let gamepad = gamepad, let name = SDL_GetJoystickName(gamepad) else {
      guard let name = SDL_GetJoystickNameForID(id) else {
        return ""
      }
      return String(cString: name)
    }
    return String(cString: name)
  }
  
  public var gamepad: OpaquePointer? {
    guard case(.open) = self else {
      return nil
    }
    return SDL_GetGamepadFromID(id)
  }
  
  public var gamepadName: String {
    guard let gamepad = gamepad, let name = SDL_GetGamepadName(gamepad) else {
      guard let name = SDL_GetGamepadNameForID(id) else {
        return ""
      }
      return String(cString: name)
    }
    return String(cString: name)
  }
  
  public mutating func open() throws(SDL_Error) {
    guard case(.connected) = self else {
      return
    }
    
    print("Opening \(SDL_IsGamepad(id) ? "#\(self) gamepad..." : "#\(id) joystick...")")
    let OpenFunc = SDL_IsGamepad(id) ? SDL_OpenGamepad : SDL_OpenJoystick
    
    guard let pointer = OpenFunc(id) else {
      throw SDL_Error.error
    }
    
    self = .open(pointer)
  }
  
  public mutating func close() {
    guard case(.open) = self else {
      return
    }
    
    if SDL_IsJoystickVirtual(id) {
      print("Detaching virtual joystick...")
      SDL_DetachVirtualJoystick(id)
    }
    
    if SDL_IsGamepad(id) {
      print("Closing gamepad...")
    }
    else {
      print("Closing joystick...")
    }
    
    SDL_CloseJoystick(joystick)
    self = .invalid
  }
}

extension SDL_JoystickID {
  var gameController: GameController {
    guard let pointer = SDL_GetJoystickFromID(self) else {
      return self == .zero ? .invalid : .connected(self)
    }
    return .open(pointer)
  }
}

