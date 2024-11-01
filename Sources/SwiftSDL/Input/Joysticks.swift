public final class JoystickPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
    print("Closing joystick...")
    SDL_CloseJoystick(pointer)
  }
}


public enum Joysticks {
  public static var connected: Result<[JoystickID], SDL_Error> {
    var deviceCount: Int32 = 0
    guard let devicePtr = SDL_GetJoysticks(&deviceCount) else {
      return .failure(.error)
    }
    defer { SDL_free(devicePtr) }
    
    var devices = [JoystickID](repeating: .invalid, count: Int(deviceCount))
    for index in 0..<Int(deviceCount) {
      devices[index] = .connected(devicePtr[index])
    }
    
    return .success(devices)
  }
  
  @discardableResult
  public static func attachVirtual(
    type: SDL_JoystickType,
    vendorID: UInt16 = .zero,
    productID: UInt16 = .zero,
    ballsCount: Int32 = .zero,
    hatsCount: Int32 = .zero,
    buttons: [SDL_GamepadButton] = [],
    axises: [SDL_GamepadAxis] = [],
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
  ) throws(SDL_Error) -> JoystickID {
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
    guard virtualID != JoystickID.invalid.id else {
      throw SDL_Error.error
    }
    
    return .connected(virtualID)
  }
}

// @dynamicMemberLookup
public enum JoystickID: Decodable {
  private enum CodingKeys: String, CodingKey {
    case joystickID
  }
  
  case connected(SDL_JoystickID)
  case open(pointer: JoystickPtr.Value)
  case invalid
  
  // FIXME: Is a system-wide joystick probe occurring during decoding a good idea?
  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.container(keyedBy: CodingKeys.self)
    let joystickID = try decoder.decode(SDL_JoystickID.self, forKey: .joystickID)
    let connected = try Joysticks.connected.get()
    guard connected.contains(where: { $0.id == joystickID }) else {
      self = .invalid
      return
    }
    self = .connected(joystickID)
  }
  
  public var id: SDL_JoystickID {
    switch self {
      case .connected(let id): return id
      case .open(let ptr): return SDL_GetJoystickID(ptr)
      case .invalid: return .zero
    }
  }
  
  public var name: Result<String, SDL_Error> {
    func nameFormatted(_ name: UnsafePointer<CChar>!) -> String {
      let name = String(cString: name)
      switch (name.isEmpty, isVirtual) {
        case (true, true): return "Virtual Joystick (\(type))"
        case (true, false): return "Unknown Joystick \(type)"
        default: return name
      }
    }
    
    guard case(.open(let ptr)) = self else {
      guard let name = SDL_GetJoystickNameForID(id) else {
        return .failure(.error)
      }
      return .success(nameFormatted(name))
    }
    
    guard let name = SDL_GetJoystickName(ptr) else {
      return .failure(.error)
    }

    return .success(nameFormatted(name))
  }
  
  @discardableResult
  public func open() throws(SDL_Error) -> Self {
    switch self {
      case .open: return self
      default:
        guard let pointer = SDL_OpenJoystick(id) else {
          throw SDL_Error.error
        }
        return .open(pointer: pointer)
    }
  }

  public mutating func close() throws(SDL_Error) {
    guard case(.open(let pointer)) = self else {
      return
    }
    
    guard !self.isVirtual else {
      print("Detaching virtual device...")
      if !SDL_DetachVirtualJoystick(id) {
        throw SDL_Error.error
      }
      
      self = .invalid
      JoystickPtr.destroy(pointer)
      return
    }
    
    self = .connected(id)
    JoystickPtr.destroy(pointer)
  }
}

extension JoystickID: CustomDebugStringConvertible {
  public var debugDescription: String {
    guard case(.success(let name)) = name else {
      return "INVALID JOYSTICK DEVICE"
    }
    return name
  }
  
  public var guid: SDL_GUID {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickGUIDForID(id)
    }
    
    return SDL_GetJoystickGUID(ptr)
  }
  
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var type: SDL_JoystickType {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickTypeForID(id)
    }
    
    return SDL_GetJoystickType(ptr)
  }
  
  public var vendorID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickVendorForID(id)
    }
    
    return SDL_GetJoystickVendor(ptr)
  }
  
  public var productID: UInt16 {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickProductForID(id)
    }
    
    return SDL_GetJoystickProduct(ptr)
  }
  
  public var serial: String {
    guard case(.open(let ptr)) = self else {
      return ""
    }
    
    guard let serial = SDL_GetJoystickSerial(ptr) else {
      return ""
    }
    
    return String(cString: serial)
  }
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

extension SDL_VirtualJoystickDesc {
  public final class UserData {
    public typealias DataType = [String:AnyHashable]
    
    fileprivate let _userData: DataType
    fileprivate let _update: (DataType) -> Void
    fileprivate let _setPlayerIndex: (DataType, Int32) -> Void
    fileprivate let _rumble: (DataType, UInt16, UInt16) -> Bool
    fileprivate let _rumbleTriggers: (DataType, UInt16, UInt16) -> Bool
    fileprivate let _setLED: (DataType, UInt8, UInt8, UInt8) -> Bool
    fileprivate let _sendEffect: (DataType, UnsafeRawPointer?, Int32) -> Bool
    fileprivate let _setSensorsEnabled: (DataType, Bool) -> Bool
    fileprivate let _cleanup: (DataType) -> Void

    fileprivate init(
      _ userData: DataType,
      update: ((DataType) -> Void)? = nil,
      setPlayerIndex: ((DataType, Int32) -> Void)? = nil,
      rumble: ((DataType, UInt16, UInt16) -> Bool)? = nil,
      rumbleTriggers: ((DataType, UInt16, UInt16) -> Bool)? = nil,
      setLED: ((DataType, UInt8, UInt8, UInt8) -> Bool)? = nil,
      sendEffect: ((DataType, UnsafeRawPointer?, Int32) -> Bool)? = nil,
      setSensorsEnabled: ((DataType, Bool) -> Bool)? = nil,
      cleanup: ((DataType) -> Void)? = nil
    ) {
      self._userData = userData
      self._update = update ?? { _ in }
      self._setPlayerIndex = setPlayerIndex ?? { _, _ in }
      self._rumble = rumble ?? { _, _, _ in true }
      self._rumbleTriggers = rumbleTriggers ?? { _, _, _ in true }
      self._setLED = setLED ?? { _, _, _, _ in true }
      self._sendEffect = sendEffect ?? { _, _, _ in true }
      self._setSensorsEnabled = setSensorsEnabled ?? { _, _ in true }
      self._cleanup = cleanup ?? { _ in }
    }
    
    deinit {
      print("UserData: deinit")
    }
  }
  
  internal init(
    version: Int = MemoryLayout<Self>.size,
    type: SDL_JoystickType,
    vendorID: UInt16 = .zero,
    productID: UInt16 = .zero,
    ballsCount: Int32 = .zero,
    hatsCount: Int32 = .zero,
    buttons: [SDL_GamepadButton] = [],
    axises: [SDL_GamepadAxis] = [],
    name: String = "",
    touchpads: [SDL_VirtualJoystickTouchpadDesc] = [],
    sensors: [SDL_VirtualJoystickSensorDesc] = [],
    userdata: UserData.DataType = .init(),
    update: ((UserData.DataType) -> Void)? = nil,
    setPlayerIndex: ((UserData.DataType, Int32) -> Void)? = nil,
    rumble: ((UserData.DataType, Uint16, Uint16) -> Bool)? = nil,
    rumbleTriggers: ((UserData.DataType, Uint16, Uint16) -> Bool)? = nil,
    setLED: ((UserData.DataType, Uint8, Uint8, Uint8) -> Bool)? = nil,
    sendEffect: ((UserData.DataType, UnsafeRawPointer?, Int32) -> Bool)? = nil,
    setSensorsEnabled: ((UserData.DataType, Bool) -> Bool)? = nil,
    cleanup: ((UserData.DataType) -> Void)? = nil
  ) {
    var touchpads = touchpads
    var sensors = sensors
    let userData = UserData(
      userdata,
      update: update,
      setPlayerIndex: setPlayerIndex,
      rumble: rumble,
      rumbleTriggers: rumbleTriggers,
      setLED: setLED,
      sendEffect: sendEffect,
      setSensorsEnabled: setSensorsEnabled,
      cleanup: cleanup
    )
    
    self.init(
      version: UInt32(version),
      type: UInt16(type.rawValue),
      padding: .zero,
      vendor_id: vendorID,
      product_id: productID,
      naxes: UInt16(axises.count),
      nbuttons: UInt16(buttons.count),
      nballs: UInt16(ballsCount),
      nhats: UInt16(hatsCount),
      ntouchpads: UInt16(touchpads.count),
      nsensors: UInt16(sensors.count),
      padding2: (.zero, .zero),
      button_mask: UInt32(buttons.reduce(0) { $0 | $1.rawValue }),
      axis_mask: UInt32(axises.reduce(0) { $0 | $1.rawValue }),
      name: name.utf8CString.withUnsafeBufferPointer(\.baseAddress),
      touchpads: touchpads.withUnsafeMutableBufferPointer(\.baseAddress),
      sensors: sensors.withUnsafeMutableBufferPointer(\.baseAddress),
      userdata: Unmanaged.passRetained(userData).toOpaque(),
      Update: SDL_VirtualJoystickUpdate,
      SetPlayerIndex: SDL_VirtualJoystickSetPlayerIndex,
      Rumble: SDL_VirtualJoystickRumble,
      RumbleTriggers: SDL_VirtualJoystickRumbleTriggers,
      SetLED: SDL_VirtualJoystickSetLED,
      SendEffect: SDL_VirtualJoystickSendEffect,
      SetSensorsEnabled: SDL_VirtualJoystickSetSensorsEnabled,
      Cleanup: SDL_VirtualJoystickCleanup
    )
  }
}

fileprivate func SDL_VirtualJoystickUpdate(_ userData: UnsafeMutableRawPointer?) {
  guard let userData = userData else { return }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._update
  let argUserData = userDataValue._userData
  callback(argUserData)
}

fileprivate func SDL_VirtualJoystickSetPlayerIndex(_ userData: UnsafeMutableRawPointer?, playerIndex: Int32) {
  guard let userData = userData else { return }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._setPlayerIndex
  let argUserData = userDataValue._userData
  callback(argUserData, playerIndex)
}


fileprivate func SDL_VirtualJoystickRumble(_ userData: UnsafeMutableRawPointer?, lowFrequency: Uint16, highFrequency: Uint16) -> Bool {
  guard let userData = userData else { return false }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._rumble
  let argUserData = userDataValue._userData
  return callback(argUserData, lowFrequency, highFrequency)
}

fileprivate func SDL_VirtualJoystickRumbleTriggers(_ userData: UnsafeMutableRawPointer?, leftRumble: Uint16, rightRumble: Uint16) -> Bool {
  guard let userData = userData else { return false }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._rumbleTriggers
  let argUserData = userDataValue._userData
  return callback(argUserData, leftRumble, rightRumble)
}

fileprivate func SDL_VirtualJoystickSetLED(_ userData: UnsafeMutableRawPointer?, red: UInt8, green: UInt8, blue: UInt8) -> Bool {
  guard let userData = userData else { return false }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._setLED
  let argUserData = userDataValue._userData
  return callback(argUserData, red, green, blue)
}

fileprivate func SDL_VirtualJoystickSendEffect(_ userData: UnsafeMutableRawPointer?, data: UnsafeRawPointer?, size: Int32) -> Bool {
  guard let userData = userData else { return false }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._sendEffect
  let argUserData = userDataValue._userData
  return callback(argUserData, data, size)
}

fileprivate func SDL_VirtualJoystickSetSensorsEnabled(_ userData: UnsafeMutableRawPointer?, enabled: Bool) -> Bool {
  guard let userData = userData else { return false }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let callback = userDataValue._setSensorsEnabled
  let argUserData = userDataValue._userData
  return callback(argUserData, enabled)
}

fileprivate func SDL_VirtualJoystickCleanup(_ userData: UnsafeMutableRawPointer?) {
  guard let userData = userData else { return }
  
  // 'deinit' the UserData
  let _ = Unmanaged<SDL_VirtualJoystickDesc.UserData>
    .fromOpaque(userData)
    .takeRetainedValue()
}
