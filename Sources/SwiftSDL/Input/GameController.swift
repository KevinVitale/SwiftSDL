@discardableResult
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
    guard let joystick = joystick, let name = SDL_GetJoystickName(joystick) else {
      guard let name = SDL_GetJoystickNameForID(id) else {
        return ""
      }
      return String(cString: name)
    }
    return String(cString: name)
  }
  
  public var joystickSerial: String {
    guard let serial = SDL_GetJoystickSerial(joystick) else {
      return ""
    }
    return String(cString: serial)
  }
  
  public func buttonIndices() -> [Int32] {
    guard case(.open) = self else {
      return []
    }

    let buttonCount =  SDL_GetNumJoystickButtons(joystick)
    return Array(0..<buttonCount)
  }

  public func joystick(isPressed button: Int32) -> Bool {
    SDL_GetJoystickButton(joystick, button)
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
  
  public var gamepadType: SDL_GamepadType {
    SDL_GetGamepadType(gamepad)
  }
  
  public var gamepadSteamHandle: Uint64 {
    SDL_GetGamepadSteamHandle(gamepad)
  }
  
  public var gamepadSerial: String {
    guard let serial = SDL_GetGamepadSerial(gamepad) else {
      return ""
    }
    return String(cString: serial)
  }
  
  public func gamepad(labelFor button: SDL_GamepadButton) -> SDL_GamepadButtonLabel {
    let type = SDL_GetGamepadType(gamepad)
    guard type != .unknown else {
      return .unknown
    }
    return SDL_GetGamepadButtonLabelForType(type, button)
  }
  
  public func gamepad(isPressed button: SDL_GamepadButton) -> Bool {
    SDL_GetGamepadButton(gamepad, button)
  }

  public func gamepad(has button: SDL_GamepadButton) -> Bool {
    SDL_GamepadHasButton(gamepad, button)
  }
  
  public func gamepad(has axis: SDL_GamepadAxis) -> Bool {
    SDL_GamepadHasAxis(gamepad, axis)
  }
  
  public func gamepad(has sensor: SDL_SensorType) -> Bool {
    SDL_GamepadHasSensor(gamepad, sensor)
  }
  
  public func gamepad(enables sensor: SDL_SensorType) -> Bool {
    SDL_GamepadSensorEnabled(gamepad, sensor)
  }
  
  @discardableResult
  public func gamepad(activate sensor: SDL_SensorType) -> Bool {
    guard !gamepad(enables: sensor) else { return true }
    print("Activating: \(sensor)")
    return SDL_SetGamepadSensorEnabled(gamepad, sensor, true)
  }
  
  @discardableResult
  public func gamepad(deactivate sensor: SDL_SensorType) -> Bool {
    SDL_SetGamepadSensorEnabled(gamepad, sensor, false)
  }

  public func gamepad(query axis: SDL_GamepadAxis, normalized: Bool = false) -> Sint16 {
    let value = SDL_GetGamepadAxis(gamepad, axis)
    if normalized {
      // TODO: Normalize axis value
    }
    return value
  }
  
  public func gamepad(query button: SDL_GamepadButton) -> Bool {
    SDL_GetGamepadButton(gamepad, button)
  }
  
  public func gamepad(rate sensor: SDL_SensorType) -> Float {
    SDL_GetGamepadSensorDataRate(gamepad, sensor)
  }
  
  public func gamepad(query sensor: SDL_SensorType) -> SDL_SensorData {
    guard sensor != .invalid, sensor != .unknown else {
      return .none
    }
    
    var data = Array(repeating: Float.zero, count: 3)
    SDL_GetGamepadSensorData(gamepad, sensor, .some(&data), 3)

    switch sensor {
      case .accelerometer: fallthrough
      case .leftAccelerometer: fallthrough
      case .rightAccelerometer:
        return .accelerometer(
          x: data[0],
          y: data[1],
          z: data[2]
        )
      case .gyroscope: fallthrough
      case .leftGyroscope: fallthrough
      case .rightGyroscope:
        return .gyroscope(
          pitch: data[0],
          yaw: data[1],
          roll: data[2]
        )
        
      default: return .none
    }
  }

  public func gamepadAxes() -> [SDL_GamepadAxis] {
    var axes = [SDL_GamepadAxis]()
    for axis in SDL_GamepadAxis.allCases {
      if gamepad(has: axis) {
        axes.append(axis)
      }
    }
    return axes
  }
  
  public func gamepadButtons() -> [SDL_GamepadButton] {
    var buttons = [SDL_GamepadButton]()
    for button in SDL_GamepadButton.allCases {
      if gamepad(has: button) {
        buttons.append(button)
      }
    }
    return buttons
  }
  
  public func gamepadSensors() -> [SDL_SensorType] {
    var sensors = [SDL_SensorType]()
    for sensor in SDL_SensorType.allCases {
      if gamepad(has: sensor) {
        sensors.append(sensor)
      }
    }
    return sensors
  }
  
  public var guid: SDL_GUID {
    guard case(.open) = self else {
      return SDL_GetJoystickGUIDForID(id)
    }
    
    return SDL_GetJoystickGUID(joystick)
  }

  public mutating func open() throws(SDL_Error) {
    guard case(.connected) = self else {
      return
    }
    
    print("Opening \(SDL_IsGamepad(id) ? "#\(id) gamepad..." : "#\(id) joystick...")")
    let OpenFunc = SDL_IsGamepad(id) ? SDL_OpenGamepad : SDL_OpenJoystick
    
    guard let pointer = OpenFunc(id) else {
      throw SDL_Error.error
    }
    
    self = .open(pointer)
    GameControllers = try SDL_BufferPointer(SDL_GetJoysticks).map(\.gameController)
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
      print("Closing gamepad:", gamepadName)
      SDL_CloseGamepad(gamepad)
    }
    else {
      print("Closing joystick:", joystickName)
      SDL_CloseJoystick(joystick)
    }
    
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

@propertyWrapper
public struct SDL_GamepadMapping: CaseIterable {
  public init(guid: SDL_GUID) throws {
    guard let mapping = SDL_GetGamepadMappingForGUID(guid) else {
      throw SDL_Error.error
    }
    defer { SDL_free(mapping) }
    self.init(wrappedValue: String(cString: mapping))
  }
  
  public init(wrappedValue mapping: String) {
    self.wrappedValue = mapping
    var components = Array(mapping.split(separator: ","))
    
    self.guid = SDL_StringToGUID(String(components.removeFirst()))
    self.name = String(components.removeFirst())
    
    for (key, value) in components
      .map({
        let separatorIndex = $0.firstIndex(of: ":")!
        let key = String($0[..<separatorIndex])
        let value = String($0[separatorIndex...].dropFirst())
        return (key: key, value: value)
      }) {
      self.keyValues[key] = value
    }
  }

  public let guid: SDL_GUID
  public let name: String
  public var platform: String {
    keyValues["platform"] ?? ""
  }
  
  public let wrappedValue: String
  
  private var keyValues: [String: String] = [:]
  
  public subscript(key: String) -> String? {
    get { keyValues[key] }
    set { keyValues[key] = newValue }
  }
  
  public static func matching(_ callback: (Self) -> Bool) -> [Self] {
    allCases.filter(callback)
  }

  public static var allCases: [Self] {
    do {
      return try SDL_BufferPointer(SDL_GetGamepadMappings)
        .compactMap({
          guard let mappings = $0 else {
            return nil
          }
          return String(cString: mappings)
        })
        .map(Self.init(wrappedValue:))
    }
    catch {
      return []
    }
  }
}

public enum SDL_JoystickHat: CaseIterable {
  case centered
  case up
  case right
  case down
  case left
  case rightUp
  case rightDown
  case leftUp
  case leftDown
  
  var rawValue: UInt8 {
    switch self {
      case .centered: return UInt8(SDL_HAT_CENTERED)
      case .up: return UInt8(SDL_HAT_UP)
      case .right: return  UInt8(SDL_HAT_RIGHT)
      case .down: return  UInt8(SDL_HAT_DOWN)
      case .left: return UInt8(SDL_HAT_LEFT)
      case .rightUp: return UInt8(SDL_HAT_RIGHTUP)
      case .rightDown: return UInt8(SDL_HAT_RIGHTDOWN)
      case .leftUp: return UInt8(SDL_HAT_LEFTUP)
      case .leftDown: return UInt8(SDL_HAT_LEFTDOWN)
    }
  }
}
