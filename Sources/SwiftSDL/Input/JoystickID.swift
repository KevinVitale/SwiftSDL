public enum JoystickID: Decodable {
  public typealias JoystickPtr = OpaquePointer
  
  private enum CodingKeys: String, CodingKey {
    case joystickID
  }
  
  case connected(SDL_JoystickID)
  case open(pointer: JoystickPtr)
  case invalid
  
  public init(from decoder: any Decoder) throws {
    let decoder = try decoder.container(keyedBy: CodingKeys.self)
    let joystickID = try decoder.decode(SDL_JoystickID.self, forKey: .joystickID)
    let available = try Cameras.connected.get()
    guard available.contains(where: { $0.id == joystickID }) else {
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
  
  public var guid: SDL_GUID {
    guard case(.open(let ptr)) = self else {
      return SDL_GetJoystickGUIDForID(id)
    }
    
    return SDL_GetJoystickGUID(ptr)
  }
  
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var isGamepad: Bool {
    SDL_IsGamepad(id)
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
        print("Opening \((try? name.get()) ?? "")...")
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
      SDL_CloseJoystick(pointer)
      return
    }
    
    self = .connected(id)
    SDL_CloseJoystick(pointer)
  }
  
  public func set<PlayerIndex: FixedWidthInteger>(playerIndex: PlayerIndex) throws(SDL_Error) {
    guard case(.open(let pointer)) = self, isGamepad else {
      return
    }
    
    guard SDL_SetGamepadPlayerIndex(pointer, Int32(playerIndex)) else {
      throw SDL_Error.error
    }
  }
}

extension JoystickID: CustomDebugStringConvertible {
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
