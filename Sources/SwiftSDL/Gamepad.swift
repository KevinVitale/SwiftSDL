public enum Gamepad: Hashable {
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
  
  public static var connected: Result<[Gamepad], SDL_Error> {
    Result { () throws(SDL_Error) in
      let gamepadsIDs = try SDL_BufferPointer(SDL_GetGamepads)
      let gamepads = gamepadsIDs.map { (id: SDL_JoystickID) -> Self in
        guard let pointer = SDL_GetGamepadFromID(id) else {
          return .connected(id)
        }
        return .open(pointer)
      }
      return gamepads
    }
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
  
  public func joystickButtons() -> [Int32] {
    guard case(.open) = self else {
      return []
    }
    
    return Array(0..<SDL_GetNumJoystickButtons(joystick))
  }
  
  public func joystickAxes() -> [Int32] {
    guard case(.open) = self else {
      return []
    }
    
    let axisCount = SDL_GetNumJoystickAxes(joystick)
    return Array(0..<axisCount)
  }
  
  public func joystickHats() -> [Int32] {
    guard case(.open) = self else {
      return []
    }
    
    let hatsCount = SDL_GetNumJoystickHats(joystick)
    return Array(0..<hatsCount)
  }
  
  
  public func joystick(isPressed button: Int32) -> Bool {
    SDL_GetJoystickButton(joystick, button)
  }
  
  public func joystick(axis: Int32) -> Sint16 {
    SDL_GetJoystickAxis(joystick, axis)
  }
  
  public var gamepad: OpaquePointer? {
    guard case(.open) = self else {
      return nil
    }
    return SDL_GetGamepadFromID(id)
  }
}
  
extension Gamepad {
  public static var isConnected: Bool { SDL_HasGamepad() }
  
  public var name: Result<String, SDL_Error> {
    Result { () throws(SDL_Error) in
      switch self {
        case .connected(let id):
          switch SDL_GetGamepadNameForID(id) {
            case .none: throw SDL_Error.error
            case .some(let cString): return String(cString: cString)
          }
        case .open(let pointer):
          switch SDL_GetGamepadName(pointer) {
            case .none: throw SDL_Error.error
            case .some(let cString): return String(cString: cString)
          }
        case .invalid: return ""
      }
    }
  }
  
  public var path: Result<String, SDL_Error> {
    Result { () throws(SDL_Error) in
      switch self {
        case .connected(let id):
          switch SDL_GetGamepadPathForID(id) {
            case .none: throw SDL_Error.error
            case .some(let cString): return String(cString: cString)
          }
        case .open(let pointer):
          switch SDL_GetGamepadPath(pointer) {
            case .none: throw SDL_Error.error
            case .some(let cString): return String(cString: cString)
          }
        case .invalid: return ""
      }
    }
  }
  
  public var playerIndex: Int? {
    switch self {
      case .connected(let id):
        switch SDL_GetGamepadPlayerIndexForID(id) {
          case -1: return nil
          case let index: return Int(index)
        }
      case .open(let pointer):
        switch SDL_GetGamepadPlayerIndex(pointer) {
          case -1: return nil
          case let index: return Int(index)
        }
      default: return nil
    }
  }

  public var type: SDL_GamepadType {
    switch self {
      case .connected(let id): return SDL_GetGamepadTypeForID(id)
      case .open(let pointer): return SDL_GetGamepadType(pointer)
      case .invalid: return .unknown
    }
  }
  
  public var guid: SDL_GUID? {
    let guid = SDL_GetGamepadGUIDForID(id)
    if guid.isZero { return nil }
    return guid
  }
  
  public var state: Result<SDL_JoystickConnectionState, SDL_Error> {
    Result { () throws(SDL_Error) in
      switch self {
        case .open(let pointer): return SDL_GetGamepadConnectionState(pointer)
        default: return .invalid
      }
    }
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
      case .accelerometerLeft: fallthrough
      case .accelerometerRight:
        return .accelerometer(
          x: data[0],
          y: data[1],
          z: data[2]
        )
      case .gyroscope: fallthrough
      case .gyroscopeLeft: fallthrough
      case .gryoscopeRight:
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

  public mutating func open() throws(SDL_Error) {
    guard case(.connected(let id)) = self else {
      return
    }

    let OpenFunc = SDL_IsGamepad(id) ? SDL_OpenGamepad : SDL_OpenJoystick
    
    guard OpenFunc(id) != nil else {
      throw .error
    }
    
    __GameControllers = try SDL_BufferPointer(SDL_GetJoysticks).map(\.gameController)
    self = __GameControllers.filter { $0.id == id }.first! 
  }
  
  public mutating func close() {
    guard case(.open) = self else {
      return
    }
    
    if SDL_IsJoystickVirtual(id) {
      SDL_DetachVirtualJoystick(id)
    }
    
    if SDL_IsGamepad(id) {
      SDL_CloseGamepad(gamepad)
    }
    else {
      SDL_CloseJoystick(joystick)
    }
    
    self = .invalid
  }
}

extension SDL_GamepadButton {
  public func isAvailable(on controller: Gamepad) -> Bool {
    guard case(.open) = controller else {
      return false
    }
    return controller.gamepad(has: self)
  }
  
  public func isPressed(by controller: Gamepad) -> Bool {
    guard case(.open) = controller else {
      return false
    }
    return controller.gamepad(isPressed: self)
  }
  
  public func label(for controller: Gamepad) -> SDL_GamepadButtonLabel {
    guard case(.open) = controller else {
      return SDL_GetGamepadButtonLabelForType(controller.gamepadType, self)
    }
    
    return SDL_GetGamepadButtonLabel(controller.gamepad, self)
  }
}

extension SDL_JoystickID {
  var gameController: Gamepad {
    guard let pointer = SDL_GetJoystickFromID(self) else {
      return self == .zero ? .invalid : .connected(self)
    }
    return .open(pointer)
  }
}

@propertyWrapper
public struct SDL_GamepadMapping: CaseIterable {
  public init(guid: SDL_GUID) throws(SDL_Error) {
    guard let mapping = SDL_GetGamepadMappingForGUID(guid) else {
      throw .error
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

public enum _Gamepad: SDL_Gamepad {
  case invalid
  case connected(ID)
  case open(OpaquePointer)
  
  public var id: UInt32 {
    switch self {
      case .invalid: return .zero
      case .connected(let id): return id
      case .open(let pointer): return SDL_GetGamepadID(pointer)
    }
  }
  

  public static var connected: Result<[Self], SDL_Error> {
    do {
      let joystickIDs = try SDL_BufferPointer(SDL_GetGamepads)
      let joysticks = joystickIDs.map { (id: SDL_JoystickID) -> Self in
        guard let pointer = SDL_GetGamepadFromID(id) else { return .connected(id) }
        return .open(pointer)
      }
      return .success(joysticks)
    }
    catch {
      return .failure(error)
    }
  }
  
  public static var isConnected: Bool {
    SDL_HasGamepad()
  }
  
  public static func locate(fromID id: UInt32) -> Result<Self, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard id != .zero else { return .invalid }
      
      let joysticks = try connected.get()
      let joystick = joysticks.first(where: { $0.id == id })
      
      return joystick ?? .invalid
    }  }
  
  public static func locate(fromPlayer index: Int32) -> Result<Self, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard let pointer = SDL_GetGamepadFromPlayerIndex(index) else {
        throw .error
      }
      return .open(pointer)
    }

  }
  
  public static func lock(_ closure: () throws(SDL_Error) -> ()) rethrows {
    try Joystick.lock(closure)
  }
  
  public var joystick: Result<Joystick, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadJoystick)
      .map { Joystick.open($0) }
  }
  
  public static var enabled: Bool {
    get { SDL_GamepadEventsEnabled() }
    set { SDL_SetGamepadEventsEnabled(newValue) }
  }
  
  public static func update() {
    SDL_UpdateGamepads()
  }
  
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var isGamepad: Bool {
    SDL_IsGamepad(id)
  }
  
  public var pointer: Result<OpaquePointer, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard case(.open(let pointer)) = self, SDL_GamepadConnected(pointer)
      else { throw .error }
      return pointer
    }
  }

  public mutating func open() throws(SDL_Error) {
    guard case(.connected) = self else { return }
    self = .open(try self(SDL_OpenGamepad))
  }
  
  public mutating func close() throws(SDL_Error) {
    if isVirtual { _ = try self.detach.get() }
    try self(SDL_CloseGamepad)
    self = .invalid
  }
  
  /**
   - seealso: `SDL_DetachVirtualJoystick`
   */
  fileprivate var detach: Result<Joystick, SDL_Error> {
    self
      .joystick
      .flatMap { $0.resultOf(SDL_DetachVirtualJoystick) }
  }
  
  public func initialState(of axis: Int32) -> Result<Int16, SDL_Error> {
    var state: Sint16! = .zero
    return self
      .resultOf(SDL_GetJoystickAxisInitialState, axis, .some(&state))
      .map { _ in state }
  }
  
  public var connectionState: Result<SDL_JoystickConnectionState, SDL_Error> {
    self.resultOf(SDL_GetGamepadConnectionState)
  }
  
  public var firmwareVersion: Result<UInt16, SDL_Error> {
    self.resultOf(SDL_GetGamepadFirmwareVersion)
  }
  
  public var playerIndex: Result<Int32, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadPlayerIndex)
      .flatMapError { _ in
        self.resultOf(SDL_GetGamepadPlayerIndexForID)
      }
  }
  
  public func set(playerIndex: Int32) throws(SDL_Error) {
    try self(SDL_SetGamepadPlayerIndex, playerIndex)
  }
  
  public var GUID: Result<SDL_GUID, SDL_Error> {
    self.resultOf(SDL_GetGamepadGUIDForID)
  }
  
  public var GUIDInfo: Result<(vendor: UInt16, product: UInt16, version: UInt16, crc16: UInt16), SDL_Error> {
    self
      .joystick
      .flatMap { $0.GUIDInfo }
  }
  
  public var name: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadName)
      .map(String.init(cString:))
      .flatMapError { _ in
        self.resultOf(SDL_GetGamepadNameForID)
          .map(String.init(cString:))
      }
  }
  
  public var path: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadPath)
      .map(String.init(cString:))
      .flatMapError { _ in
        self.resultOf(SDL_GetGamepadPathForID)
          .map(String.init(cString:))
      }
  }
  
  public var power: Result<(battery: SDL_PowerState, percent: Int32), SDL_Error> {
    var percent: Int32! = 0
    return self
      .resultOf(SDL_GetGamepadPowerInfo, .some(&percent))
      .flatMap { state in
        switch state {
          case .error: return .failure(.error)
          default: return .success((state, percent))
        }
      }
  }
  
  public var productID: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadProduct)
      .flatMap { _ in
        self.resultOf(SDL_GetGamepadProductForID)
      }
  }
  
  public var productVersion: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadProductVersion)
      .flatMap { _ in
        self.resultOf(SDL_GetGamepadProductVersionForID)
      }
  }
  
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadProperties)
      .flatMap { propertyID in
        Result { () throws(SDL_Error) in
          guard propertyID != 0 else { throw .error }
          return try SDL_PropertiesID(id: propertyID)
        }
      }
  }
  
  public var serial: Result<String, SDL_Error> {
    self
      .pointer
      .flatMap {
        guard let cString = SDL_GetGamepadSerial($0)
        else { return .success("") }
        return .success(String(cString: cString))
      }
  }
  
  public var type: Result<SDL_GamepadType, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadType)
      .flatMap { _ in
        self.resultOf(SDL_GetGamepadTypeForID)
      }
  }
  
  public var vendor: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetGamepadVendor)
      .flatMap { _ in
        self.resultOf(SDL_GetGamepadVendorForID)
      }
  }
  
  public var axes: Result<Range<Int32>, SDL_Error> {
    .success(
      SDL_GamepadAxis.leftX.rawValue..<SDL_GamepadAxis.axisCount.rawValue
    )
  }
  
  public subscript<T: BinaryInteger>(axis indices: T...) -> Result<[(Int32, Int16)], SDL_Error> where T: Sendable {
    return self.axis(indices.map(Int32.init))
  }
  
  public subscript<T: RangeExpression>(axis indices: T) -> Result<[(Int32, Int16)], SDL_Error> where T.Bound == Int32 {
    self.axis(indices)
  }
  
  public subscript<T: RangeExpression>(axis indices: Result<T, SDL_Error>) -> Result<[(Int32, Int16)], SDL_Error> where T.Bound == Int32 {
    indices.flatMap { self.axis($0) }
  }
  
  public func axis<T: RangeExpression>(_ indices: T) -> Result<[(Int32, Int16)], SDL_Error> where T.Bound == Int32 {
    axes.flatMap {
      self.axis(Array(indices.relative(to: $0)))
    }
  }
  
  public func axis(_ indices: [Int32]) -> Result<[(Int32, Int16)], SDL_Error> {
    return self.pointer.map { pointer in
      indices
        .filter {
          let value = SDL_GamepadAxis(rawValue: $0) ?? .invalid
          return SDL_GamepadHasAxis(pointer, value)
        }
        .map { axis in
        let value = SDL_GamepadAxis(rawValue: axis) ?? .invalid
        return (axis, SDL_GetGamepadAxis(pointer, value))
      }
    }
  }

  public var buttons: Result<Range<Int32>, SDL_Error> {
    .success(
      SDL_GamepadButton.south.rawValue..<SDL_GamepadButton.buttonCount.rawValue
    )
  }
  
  public subscript<T: BinaryInteger>(buttons indices: T...) -> Result<[(Int32, Bool)], SDL_Error> where T: Sendable {
    self.buttons(indices.map(Int32.init))
  }
  
  public subscript<T: RangeExpression>(buttons indices: T) -> Result<[(Int32, Bool)], SDL_Error> where T.Bound == Int32 {
    self.buttons(indices)
  }
  
  public subscript<T: RangeExpression>(buttons indices: Result<T, SDL_Error>) -> Result<[(Int32, Bool)], SDL_Error> where T.Bound == Int32 {
    indices.flatMap { self.buttons($0) }
  }
  
  public func buttons<T: RangeExpression>(_ indices: T) -> Result<[(Int32, Bool)], SDL_Error> where T.Bound == Int32 {
    buttons.flatMap {
      self.buttons(Array(indices.relative(to: $0)))
    }
  }
  
  public func buttons(_ indices: [Int32]) -> Result<[(Int32, Bool)], SDL_Error> {
    return self.pointer.map { pointer in
      indices
        .filter {
          let value = SDL_GamepadButton(rawValue: $0) ?? .invalid
          return SDL_GamepadHasButton(pointer, value)
        }
        .map { button in
        let value = SDL_GamepadButton(rawValue: button) ?? .invalid
        return (button, SDL_GetGamepadButton(pointer, value))
      }
    }
  }
  
  public var hats: Result<Range<Int32>, SDL_Error> {
    self
      .resultOf(SDL_GetNumJoystickHats)
      .map { 0..<$0 }
  }
  
  public subscript<T: BinaryInteger>(hats indices: T...) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T: Sendable {
    return self.hats(indices.map(Int32.init))
  }
  
  public subscript<T: RangeExpression>(hats indices: T) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T.Bound == Int32 {
    self.hats(indices)
  }
  
  public subscript<T: RangeExpression>(hats indices: Result<T, SDL_Error>) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T.Bound == Int32 {
    indices.flatMap { self.hats($0) }
  }
  
  public func hats<T: RangeExpression>(_ indices: T) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T.Bound == Int32 {
    hats.flatMap {
      self.hats(Array(indices.relative(to: $0)))
    }
  }
  
  public func hats(_ indices: [Int32]) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> {
    return self.pointer.map { pointer in
      indices.map { hat in
        (hat, .init(rawValue: SDL_GetJoystickHat(pointer, hat)))
      }
    }
  }
  
  public var balls: Result<Range<Int32>, SDL_Error> {
    self
      .resultOf(SDL_GetNumJoystickBalls)
      .map { 0..<$0 }
  }
  
  public subscript<T: BinaryInteger>(balls indices: T...) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T: Sendable {
    return self.balls(indices.map(Int32.init))
  }
  
  public subscript<T: RangeExpression>(balls indices: T) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T.Bound == Int32 {
    self.balls(indices)
  }
  
  public subscript<T: RangeExpression>(balls indices: Result<T, SDL_Error>) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T.Bound == Int32 {
    indices.flatMap { self.balls($0) }
  }
  
  public func balls<T: RangeExpression>(_ indices: T) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T.Bound == Int32 {
    hats.flatMap {
      self.balls(Array(indices.relative(to: $0)))
    }
  }
  
  public func balls(_ indices: [Int32]) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> {
    return self.pointer.map { pointer in
      indices.map { ball in
        var xRel: Sint32! = .zero
        var yRel: Sint32! = .zero
        SDL_GetJoystickBall(pointer, ball, .some(&xRel), .some(&yRel))
        return (ball, (x: xRel, y: yRel))
      }
    }
  }
  
  public func rumble<T>(_ frequency: T, duration milliseconds: UInt32) throws(SDL_Error) where T : RangeExpression, T.Bound == UInt16 {
    let frequency = frequency.relative(to: UInt16.min..<UInt16.max)
    try self(SDL_RumbleGamepad, frequency.lowerBound, frequency.upperBound, milliseconds)
  }
  
  public func triggers<T>(_ frequency: T, duration milliseconds: UInt32) throws(SDL_Error) where T : RangeExpression, T.Bound == UInt16 {
    let frequency = frequency.relative(to: UInt16.min..<UInt16.max)
    try self(SDL_RumbleGamepadTriggers, frequency.lowerBound, frequency.upperBound, milliseconds)
  }
}
