public enum Joystick: Identifiable {
  public typealias ID = SDL_JoystickID
  public typealias JoystickPtr = OpaquePointer
  
  case connected(ID)
  case open(pointer: JoystickPtr)
  case invalid
  
  public var id: SDL_JoystickID {
    joystickID
  }
  
  public var joystickID: ID {
    switch self {
      case .connected(let id): return id
      case .open(let ptr): return SDL_GetJoystickID(ptr)
      case .invalid: return .zero
    }
  }
  
  public var gamepadID: ID {
    switch self {
      case .connected(let id): return id
      case .open(let ptr): return SDL_GetGamepadID(ptr)
      case .invalid: return .zero
    }
  }

  public var joystickGUID: SDL_GUID {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickGUIDForID(joystickID)
    }
    
    return SDL_GetJoystickGUID(ptr)
  }
  
  public var gamepadGUID: SDL_GUID {
    SDL_GetGamepadGUIDForID(gamepadID)
  }

  public var isVirtualJoystick: Bool {
    SDL_IsJoystickVirtual(joystickID)
  }
  
  public var isGamepadSupported: Bool {
    SDL_IsGamepad(joystickID)
  }
  
  public var joystickType: SDL_JoystickType {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickTypeForID(joystickID)
    }
    
    return SDL_GetJoystickType(ptr)
  }
  
  public var gamepadType: SDL_GamepadType {
    guard case(.open(let ptr)) = self else {
      return SDL_GetGamepadTypeForID(gamepadID)
    }
    
    return SDL_GetGamepadType(ptr)
  }

  public var joystickVendorID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickVendorForID(joystickID)
    }
    
    return SDL_GetJoystickVendor(ptr)
  }
  
  public var gamepadVendorID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetGamepadVendorForID(gamepadID)
    }
    
    return SDL_GetGamepadVendor(ptr)
  }

  public var joystickProductID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickProductForID(joystickID)
    }
    
    return SDL_GetJoystickProduct(ptr)
  }
  
  public var gamepadProductID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetGamepadProductForID(gamepadID)
    }
    
    return SDL_GetGamepadProduct(ptr)
  }

  public var joystickSerial: String {
    guard case(.open(let ptr)) = self else {
      return ""
    }
    
    guard let serial = SDL_GetJoystickSerial(ptr) else {
      return ""
    }
    
    return String(cString: serial)
  }
  
  public var gamepadSerial: String {
    guard case(.open(let ptr)) = self else {
      return ""
    }
    
    guard let serial = SDL_GetGamepadSerial(ptr) else {
      return ""
    }
    
    return String(cString: serial)
  }

  public var joystickName: Result<String, SDL_Error> {
    func nameFormatted(_ name: UnsafePointer<CChar>!) -> String {
      let name = String(cString: name)
      switch (name.isEmpty, isVirtualJoystick) {
        case (true, true): return "Virtual Joystick (\(joystickType))"
        case (true, false): return "Unknown Joystick \(joystickType)"
        default: return name
      }
    }
    
    guard case(.open(let ptr)) = self else {
      guard let name = SDL_GetJoystickNameForID(joystickID) else {
        return .failure(.error)
      }
      return .success(nameFormatted(name))
    }
    
    guard let name = SDL_GetJoystickName(ptr) else {
      return .failure(.error)
    }
    
    return .success(nameFormatted(name))
  }
  
  public var gamepadName: Result<String, SDL_Error> {
    func nameFormatted(_ name: UnsafePointer<CChar>!) -> String {
      let name = String(cString: name)
      switch (name.isEmpty, isVirtualJoystick) {
        case (true, true): return "Virtual Joystick (\(gamepadType))"
        case (true, false): return "Unknown Joystick \(gamepadType)"
        default: return name
      }
    }
    
    guard case(.open(let ptr)) = self else {
      guard let name = SDL_GetGamepadNameForID(joystickID) else {
        return .failure(.error)
      }
      return .success(nameFormatted(name))
    }
    
    guard let name = SDL_GetGamepadName(ptr) else {
      return .failure(.error)
    }
    
    return .success(nameFormatted(name))
  }

  @discardableResult
  public func openJoystick() throws(SDL_Error) -> Self {
    switch self {
      case .open: return self
      default:
        print("Opening \((try? joystickName.get()) ?? "")...")
        guard let pointer = SDL_OpenJoystick(joystickID) else {
          throw SDL_Error.error
        }
        return .open(pointer: pointer)
    }
  }
  
  @discardableResult
  public func openGamepad() throws(SDL_Error) -> Self {
    switch self {
      case .open: return self
      default:
        print("Opening \((try? joystickName.get()) ?? "")...")
        guard let pointer = SDL_OpenJoystick(joystickID) else {
          throw SDL_Error.error
        }
        return .open(pointer: pointer)
    }
  }

  public mutating func closeJoystick() throws(SDL_Error) {
    print("Closing joystick...")
    defer { print("Joystick closed!") }
    
    guard case(.open(let pointer)) = self else {
      return
    }
    
    guard !self.isVirtualJoystick else {
      print("Detaching virtual device...")
      if !SDL_DetachVirtualJoystick(gamepadID) {
        throw SDL_Error.error
      }
      
      self = .invalid
      SDL_CloseJoystick(pointer)
      return
    }
    
    self = .invalid
    SDL_CloseJoystick(pointer)
  }
  
  public mutating func closeGamepad() throws(SDL_Error) {
    print("Closing gamepad...")
    defer { print("Gamepad closed!") }
    
    guard case(.open(let pointer)) = self else {
      return
    }
    
    guard !self.isVirtualJoystick else {
      print("Detaching virtual device...")
      if !SDL_DetachVirtualJoystick(gamepadID) {
        throw SDL_Error.error
      }
      
      self = .invalid
      SDL_CloseGamepad(pointer)
      return
    }
    
    self = .invalid
    SDL_CloseGamepad(pointer)
  }
}
 
 extension Joystick: CustomDebugStringConvertible {
  public var debugDescription: String {
    guard case(.success(let name)) = joystickName else {
      return "INVALID JOYSTICK DEVICE"
    }
    return name
  }
}
 
 public enum Joysticks {
  @discardableResult
  @available(*, deprecated, renamed: "SDL_AttachVirtualJoystick", message: "")
  public static func attachVirtual(
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
  ) throws(SDL_Error) -> Joystick {
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
    
    return .connected(virtualID)
  }
}

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

public func SDL_ConnectedJoystickIDs() throws(SDL_Error) -> [SDL_JoystickID] {
  try SDL_BufferPointer(SDL_GetJoysticks)
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

