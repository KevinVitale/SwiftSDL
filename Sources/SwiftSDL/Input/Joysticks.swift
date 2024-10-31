public final class JoystickPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
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
}

// @dynamicMemberLookup
public enum JoystickID: Decodable, CustomDebugStringConvertible {
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
    guard case(.open(let ptr)) = self else {
      guard let name = SDL_GetJoystickNameForID(id) else {
        return .failure(.error)
      }
      return .success(String(cString: name))
    }
    
    guard let name = SDL_GetJoystickName(ptr) else {
      return .failure(.error)
    }

    return .success(String(cString: name))
  }
  
  public mutating func close() {
    guard case(.open(let pointer)) = self else {
      return
    }
    self = .connected(id)
    JoystickPtr.destroy(pointer)
  }

  public var debugDescription: String {
    guard case(.success(let name)) = name else {
      return "INVALID JOYSTICK DEVICE"
    }
    return name
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
    
    fileprivate init(
      _ userData: DataType,
      update: ((DataType) -> Void)? = nil
    ) {
      self._userData = userData
      self._update = update ?? { _ in }
    }
    
    deinit {
      print("UserData: deinit")
    }
  }
  
  public init(
    version: Int = MemoryLayout<Self>.size,
    type: SDL_JoystickType,
    vendorID: UInt16 = .zero,
    productID: UInt16 = .zero,
    axisCount: Int32 = SDL_GamepadAxis.count.rawValue,
    buttonCount: Int32 = SDL_GamepadButton.count.rawValue,
    ballsCount: Int32 = .zero,
    hatsCount: Int32 = .zero,
    buttons: [SDL_GamepadButton] = [],
    axises: [SDL_GamepadAxis] = [],
    name: String = "",
    touchpads: [SDL_VirtualJoystickTouchpadDesc] = [],
    sensors: [SDL_VirtualJoystickSensorDesc] = [],
    userdata: UserData.DataType = .init(),
    update: ((UserData.DataType) -> Void)? = nil
  ) {
    var touchpads = touchpads
    var sensors = sensors
    
    let userData = UserData(
      userdata,
      update: update
    )
    
    self.init(
      version: UInt32(version),
      type: UInt16(type.rawValue),
      padding: .zero,
      vendor_id: vendorID,
      product_id: productID,
      naxes: UInt16(axisCount),
      nbuttons: UInt16(buttonCount),
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
      SetPlayerIndex: nil,
      Rumble: nil,
      RumbleTriggers: nil,
      SetLED: nil,
      SendEffect: nil,
      SetSensorsEnabled: nil,
      Cleanup: SDL_VirtualJoystickCleanup
    )
  }
}

fileprivate func SDL_VirtualJoystickUpdate(_ userData: UnsafeMutableRawPointer?) {
  print(#function)
  
  guard let userData = userData else {
    return
  }
  
  let userDataValue = Unmanaged<SDL_VirtualJoystickDesc.UserData>.fromOpaque(userData).takeUnretainedValue()
  
  let updateFunc = userDataValue._update
  let argUserData = userDataValue._userData
  updateFunc(argUserData)
}

fileprivate func SDL_VirtualJoystickCleanup(_ userData: UnsafeMutableRawPointer?) {
  guard let userData = userData else {
    return
  }
  
  let _ = Unmanaged<SDL_VirtualJoystickDesc.UserData>
    .fromOpaque(userData)
    .takeRetainedValue()
}
