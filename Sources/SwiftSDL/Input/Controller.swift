public protocol Controller: Identifiable {
  var id: SDL_JoystickID { get }
  var isVirtual: Bool { get }
  var isGamepad: Bool { get }
  var serial: String { get }
  var guid: SDL_GUID { get }
  // var vendorID: UInt16 { get }
  // var productID: UInt16 { get }
  // var type: DeviceType { get }
  // var name: Result<String, SDL_Error> { get }
  
  mutating func open() throws(SDL_Error)
  mutating func close() throws(SDL_Error)
  // func set<PlayerIndex: FixedWidthInteger>(playerIndex: PlayerIndex) throws(SDL_Error)
}

public enum ControllerImpl: Identifiable {
  case attached(SDL_JoystickID)
  case opened(OpaquePointer)
  case invalid
  
  public var id: SDL_JoystickID {
    switch self {
      case .attached(let id): return id
      case .opened(let pointer): return SDL_GetJoystickID(pointer)
      case .invalid: return .zero
    }
  }
  
  /*
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var guid: SDL_GUID {
    guard case(.opened(let pointer)) = self else {
      let GetGUIDFunc = SDL_IsGamepad(id) ? SDL_GetGamepadGUIDForID : SDL_GetJoystickGUIDForID
      return GetGUIDFunc(id)
    }
    return SDL_GetJoystickGUID(pointer)
  }
  
  public var serial: String {
    guard case(.opened(let pointer)) = self else {
      return ""
    }
    
    let GetSerialFunc = SDL_IsGamepad(id) ? SDL_GetGamepadSerial : SDL_GetJoystickSerial
    guard let serial = GetSerialFunc(pointer) else {
      return ""
    }
    
    return String(cString: serial)
  }
  
  public mutating func open() throws(SDL_Error) {
    switch self {
      case .opened: return
      default:
        let OpenFunc = SDL_IsGamepad(id) ? SDL_OpenGamepad : SDL_OpenJoystick
        guard let pointer = OpenFunc(id) else {
          throw SDL_Error.error
        }
        self = .opened(pointer)
    }
  }
  
  public mutating func close() throws(SDL_Error) {
    guard case(.opened(let pointer)) = self else {
      return
    }
    
    guard !self.isVirtual else {
      print("Detaching virtual device...")
      if !SDL_DetachVirtualJoystick(id) {
        throw SDL_Error.error
      }
      
      self = .invalid
      return SDL_CloseJoystick(pointer)
    }
    
    self = .attached(id)
    SDL_CloseJoystick(pointer)
  }
   */
}

