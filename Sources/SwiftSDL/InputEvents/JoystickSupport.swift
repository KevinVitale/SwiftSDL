// MARK: - SDL_Joystick -
public protocol SDL_Joystick: Identifiable, Equatable, Hashable where ID == SDL_JoystickID {
  associatedtype `Type`
  typealias Pointer = OpaquePointer
  
  // MARK: - Invalid
  static var invalid: Self { get }
  
  // MARK: - ID
  /**
   - seealso: `SDL_GetJoystickGUIDForID`
   */
  
  // MARK: - Connected
  /**
   - seealso: `SDL_GetJoysticks`
   */
  static var connected: Result<[Self], SDL_Error> { get }
  
  /**
   - seealso: `SDL_HasJoystick`
   */
  static var isConnected: Bool { get }
  
  // MARK: - Locate
  static func locate(fromID id: ID) -> Result<Self, SDL_Error>
  
  /**
   - seealso: `SDL_GetJoystickFromPlayerIndex`
   */
  static func locate(fromPlayer id: Int32) -> Result<Self, SDL_Error>
  
  /**
   - seealso: `SDL_LockJoysticks`
   - seealso: `SDL_UnlockJoysticks`
   */
  static func lock(_ closure: () throws(SDL_Error) -> ()) rethrows
  
  /**
   - seealso: `SDL_JoystickEventsEnabled`
   - seealso: `SDL_SetJoystickEventsEnabled`
   */
  static var enabled: Bool { get set }

  /**
   - seealso: `SDL_UpdateJoysticks`
   */
  static func update()
  
  /**
   - seealso: `SDL_IsJoystickVirtual`
   */
  var isVirtual: Bool { get }
  
  /**
   - seealso: `SDL_IsGamepad`
   */
  var isGamepad: Bool { get }

  /**
   - seealso: `SDL_JoystickConnected`
   */
  var pointer: Result<OpaquePointer, SDL_Error> { get }

  // MARK: Open
  /// `SDL_OpenJoystick`
  mutating func open() throws(SDL_Error)
  
  // MARK: Close
  
  /**
   - seealso: `SDL_CloseJoystick`
   */
  mutating func close() throws(SDL_Error)
  
  /**
   - seealso: `SDL_GetJoystickAxisInitialState`
   */
  func initialState(of axis: Int32) -> Result<Int16, SDL_Error>
  
  /**
   - seealso: `SDL_GetJoystickConnectionState`
   */
  var connectionState: Result<SDL_JoystickConnectionState, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickFirmwareVersion`
   */
  var firmwareVersion: Result<UInt16, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickPlayerIndex`
   */
  var playerIndex: Result<Int32, SDL_Error> { get }
  
  /**
   - seealso: `SDL_SetJoystickPlayerIndex`
   */
  func set(playerIndex: Int32) throws(SDL_Error)
  
  /**
   - seealso: `SDL_GetJoystickGUID`
   - seealso: `SDL_GetJoystickGUIDForID`
   */
  var GUID: Result<SDL_GUID, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickGUIDInfo`
   */
  var GUIDInfo: Result<(
    vendor: UInt16,
    product: UInt16,
    version: UInt16,
    crc16: UInt16
  ), SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickName`
   - seealso: `SDL_GetJoystickNameForID`
   */
  var name: Result<String, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickPath`
   - seealso: `SDL_GetJoystickPathForID`
   */
  var path: Result<String, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickPowerInfo`
   */
  var power: Result<(battery: SDL_PowerState, percent: Int32), SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickProduct`
   - seealso: `SDL_GetJoystickProductForID`
   */
  var productID: Result<UInt16, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickProductVersion`
   - seealso: `SDL_GetJoystickProductVersionForID`
   */
  var productVersion: Result<UInt16, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickProperties`
   */
  var properties: Result<SDL_PropertiesID, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickSerial`
   */
  var serial: Result<String, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickType`
   - seealso: `SDL_GetJoystickTypeForID`
   */
  var type: Result<Type, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickVendor`
   - seealso: `SDL_GetJoystickVendorForID`
   */
  var vendor: Result<UInt16, SDL_Error> { get }
  
  // MARK: Axis
  /**
   - seealso: `SDL_GetNumJoystickAxes`
   */
  var axes: Result<Range<Int32>, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickAxis`
   */
  subscript<T: BinaryInteger>(axis indices: T...) -> Result<[(Int32, Int16)], SDL_Error> where T: Sendable { get }
  subscript<T: RangeExpression>(axis indices: T) -> Result<[(Int32, Int16)], SDL_Error> where T.Bound == Int32 { get }
  subscript<T: RangeExpression>(axis indices: Result<T, SDL_Error>) -> Result<[(Int32, Int16)], SDL_Error> where T.Bound == Int32 { get }
  func axis(_ indices: [Int32]) -> Result<[(Int32, Int16)], SDL_Error>

  /**
   - seealso: `SDL_GetNumJoystickButtons`
   - seealso: `SDL_GetJoystickPlayerIndexForID`
   */
  var buttons: Result<Range<Int32>, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickBall`
   */
  subscript<T: BinaryInteger>(buttons indices: T...) -> Result<[(Int32, Bool)], SDL_Error> where T: Sendable { get }
  subscript<T: RangeExpression>(buttons indices: T) -> Result<[(Int32, Bool)], SDL_Error> where T.Bound == Int32 { get }
  subscript<T: RangeExpression>(buttons indices: Result<T, SDL_Error>) -> Result<[(Int32, Bool)], SDL_Error> where T.Bound == Int32 { get }
  func buttons(_ indices: [Int32]) -> Result<[(Int32, Bool)], SDL_Error>
  
  /**
   - seealso: `SDL_GetNumJoystickHats`
   */
  var hats: Result<Range<Int32>, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickHat`
   */
  subscript<T: BinaryInteger>(hats indices: T...) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T: Sendable { get }
  subscript<T: RangeExpression>(hats indices: T) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T.Bound == Int32 { get }
  subscript<T: RangeExpression>(hats indices: Result<T, SDL_Error>) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error> where T.Bound == Int32 { get }
  func hats(_ indices: [Int32]) -> Result<[(Int32, SDL_JoystickHat)], SDL_Error>

  /**
   - seealso: `SDL_GetNumJoystickBalls`
   */
  var balls: Result<Range<Int32>, SDL_Error> { get }
  
  /**
   - seealso: `SDL_GetJoystickBall`
   */
  subscript<T: BinaryInteger>(balls indices: T...) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T: Sendable { get }
  subscript<T: RangeExpression>(balls indices: T) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T.Bound == Int32 { get }
  subscript<T: RangeExpression>(balls indices: Result<T, SDL_Error>) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error> where T.Bound == Int32 { get }
  func balls(_ indices: [Int32]) -> Result<[(Int32, (x: Int32, y: Int32))], SDL_Error>
  
  /**
   - seealso: `SDL_RumbleJoystick`
   */
  func rumble<T: RangeExpression>(_ frequency: T, duration milliseconds: UInt32) throws(SDL_Error) where T.Bound == UInt16
  
  /**
   - seealso: `SDL_RumbleJoystickTriggers`
   */
  func triggers<T: RangeExpression>(_ frequency: T, duration milliseconds: UInt32) throws(SDL_Error) where T.Bound == UInt16

  /*
  SDL_SendJoystickEffect
  SDL_SendJoystickVirtualSensorData
  SDL_SetJoystickLED
  SDL_SetJoystickVirtualAxis
  SDL_SetJoystickVirtualBall
  SDL_SetJoystickVirtualButton
  SDL_SetJoystickVirtualHat
  SDL_SetJoystickVirtualTouchpad
   */
}

extension SDL_Joystick {
  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (ID, repeat each Argument) -> Value?, _ argument: repeat each Argument) throws(SDL_Error) -> Value {
    guard let value = block(id, repeat each argument) else {
      throw .error
    }
    return value
  }
  
  @discardableResult
  @inlinable
  public func callAsFunction<each Argument>(_ block: (ID, repeat each Argument) -> Bool, _ arguments: repeat each Argument) throws(SDL_Error) -> Self {
    guard block(id, repeat each arguments) else {
      throw .error
    }
    return self
  }

  @discardableResult
  @inlinable
  public func callAsFunction<Value, each Argument>(_ block: (Pointer, repeat each Argument) -> Value?, _ argument: repeat each Argument) throws(SDL_Error) -> Value {
    let pointer = try pointer.get()
    guard let value = block(pointer, repeat each argument) else {
      throw .error
    }
    return value
  }
  
  @discardableResult
  @inlinable
  public func callAsFunction<each Argument>(_ block: (Pointer, repeat each Argument) -> Bool, _ arguments: repeat each Argument) throws(SDL_Error) -> Self {
    let pointer = try pointer.get()
    guard block(pointer, repeat each arguments) else {
      throw .error
    }
    return self
  }
  
  @discardableResult
  @inlinable
  public func resultOf<Value, each Argument>(_ block: (ID, repeat each Argument) -> Value?, _ argument: repeat each Argument) -> Result<Value, SDL_Error> {
    guard let value = block(id, repeat each argument) else {
      return .failure(.error)
    }
    return .success(value)
  }
  
  @discardableResult
  @inlinable
  public func resultOf<each Argument>(_ block: (ID, repeat each Argument) -> Bool, _ argument: repeat each Argument) -> Result<Self, SDL_Error> {
    guard block(id, repeat each argument) else {
      return .failure(.error)
    }
    return .success(self)
  }
  
  @discardableResult
  @inlinable
  public func resultOf<Value, each Argument>(_ block: (Pointer, repeat each Argument) -> Value?, _ argument: repeat each Argument) -> Result<Value, SDL_Error> {
    self.pointer.flatMap { pointer in
      guard let value = block(pointer, repeat each argument) else {
        return .failure(.error)
      }
      return .success(value)
    }
  }
  
  @discardableResult
  @inlinable
  public func resultOf<each Argument>(_ block: (Pointer, repeat each Argument) -> Bool, _ argument: repeat each Argument) -> Result<Self, SDL_Error> {
    self.pointer.flatMap { pointer in
      guard block(pointer, repeat each argument) else {
        return .failure(.error)
      }
      return .success(self)
    }
  }
}

extension SDL_JoystickType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .unknown: return "unknown"
      case .gamepad: return "gamepad"
      case .wheel: return "wheel"
      case .arcadeStick: return "arcade stick"
      case .flightStick: return "flight stick"
      case .dancePad: return "dance pad"
      case .guitar: return "guitar"
      case .drumKit: return "drum kit"
      case .arcadePad: return "arcade pad"
      case .throttle: return "throttle"
      case .typeCount: return "\(Self.typeCount.rawValue)"
      @unknown default: return "unknown"
    }
  }
  public static var allCases: [SDL_JoystickType] {
    [
      .gamepad,
      .wheel,
      .arcadeStick,
      .flightStick,
      .dancePad,
      .guitar,
      .drumKit,
      .arcadePad,
      .throttle
    ]
  }
}

extension SDL_PowerState: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .charged: return "charged"
      case .charging: return "charging"
      case .noBattery: return "noBattery"
      case .onBattery: return "onBattery"
      case .error: return "error"
      case .unknown: return "unknown"
      @unknown default: return "unknown"
    }
  }
}

public enum SDL_JoystickHat: OptionSet, CaseIterable {
  public init(rawValue: UInt8) {
    switch rawValue {
      case UInt8(SDL_HAT_CENTERED): self = .centered
      case UInt8(SDL_HAT_UP): self = .up
      case UInt8(SDL_HAT_RIGHT): self = .right
      case UInt8(SDL_HAT_DOWN): self = .down
      case UInt8(SDL_HAT_LEFT): self = .left
      case UInt8(SDL_HAT_RIGHTUP): self = .rightUp
      case UInt8(SDL_HAT_RIGHTDOWN): self = .rightDown
      case UInt8(SDL_HAT_LEFTUP): self = .leftUp
      case UInt8(SDL_HAT_LEFTDOWN): self = .leftDown
      default: self = .centered
    }
  }
  
  case centered
  case up
  case right
  case down
  case left
  case rightUp
  case rightDown
  case leftUp
  case leftDown
  
  public var rawValue: UInt8 {
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

public enum Joystick: SDL_Joystick {
  case invalid
  case connected(ID)
  case open(OpaquePointer)
  
  public static var connected: Result<[Joystick], SDL_Error> {
    do {
      let joystickIDs = try SDL_BufferPointer(SDL_GetJoysticks)
      let joysticks = joystickIDs.map { (id: SDL_JoystickID) -> Joystick in
        guard let pointer = SDL_GetJoystickFromID(id) else { return .connected(id) }
        return .open(pointer)
      }
      return .success(joysticks)
    }
    catch {
      return .failure(error)
    }
  }
  
  public static var isConnected: Bool {
    SDL_HasJoystick()
  }
  
  public static func locate(fromID id: ID) -> Result<Joystick, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard id != .zero else { return .invalid }
      
      let joysticks = try connected.get()
      let joystick = joysticks.first(where: { $0.id == id })
      
      return joystick ?? .invalid
    }
  }
  
  public static func locate(fromPlayer index: Int32) -> Result<Joystick, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard let pointer = SDL_GetJoystickFromPlayerIndex(index) else {
        throw .error
      }
      return .open(pointer)
    }
  }
  
  public static func lock(_ closure: () throws(SDL_Error) -> ()) rethrows {
    SDL_LockJoysticks()
    try closure()
    SDL_UnlockJoysticks()
  }
  
  public static var enabled: Bool {
    get { SDL_JoystickEventsEnabled() }
    set { SDL_SetJoystickEventsEnabled(newValue) }
  }
  
  public static func update() {
    SDL_UpdateJoysticks()
  }
  
  public var pointer: Result<OpaquePointer, SDL_Error> {
    Result { () throws(SDL_Error) in
      guard case(.open(let pointer)) = self, SDL_JoystickConnected(pointer)
      else { throw .error }
      return pointer
    }
  }
  
  public var id: UInt32 {
    switch self {
      case .invalid: return .zero
      case .connected(let id): return id
      case .open(let pointer): return SDL_GetJoystickID(pointer)
    }
  }
  
  public var isVirtual: Bool {
    SDL_IsJoystickVirtual(id)
  }
  
  public var isGamepad: Bool {
    SDL_IsGamepad(id)
  }

  public mutating func open() throws(SDL_Error) {
    guard case(.connected) = self else { return }
    self = .open(try self(SDL_OpenJoystick))
  }

  public mutating func close() throws(SDL_Error) {
    if isVirtual { _ = try self.detach.get() }
    try self(SDL_CloseJoystick)
    self = .invalid
  }
  
  public func initialState(of axis: Int32) -> Result<Int16, SDL_Error> {
    var state: Sint16! = .zero
    return self
      .resultOf(SDL_GetJoystickAxisInitialState, axis, .some(&state))
      .map { _ in state }
  }
  
  public var connectionState: Result<SDL_JoystickConnectionState, SDL_Error> {
    self.resultOf(SDL_GetJoystickConnectionState)
  }
  
  public var firmwareVersion: Result<UInt16, SDL_Error> {
    self.resultOf(SDL_GetJoystickFirmwareVersion)
  }
  
  public var playerIndex: Result<Int32, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickPlayerIndex)
      .flatMapError { _ in
        self.resultOf(SDL_GetJoystickPlayerIndexForID)
      }
  }
  
  public func set(playerIndex: Int32) throws(SDL_Error) {
    try self(SDL_SetJoystickPlayerIndex, playerIndex)
  }
  
  public var GUID: Result<SDL_GUID, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickGUID)
      .flatMapError { _ in
        self.resultOf(SDL_GetJoystickGUIDForID)
      }
  }
  
  public var GUIDInfo: Result<(vendor: UInt16, product: UInt16, version: UInt16, crc16: UInt16), SDL_Error> {
    GUID.flatMap { guid in
      var vendor: UInt16! = 0
      var product: UInt16! = 0
      var version: UInt16! = 0
      var crc16: UInt16! = 0
      SDL_GetJoystickGUIDInfo(
        guid,
        .some(&vendor),
        .some(&product),
        .some(&version),
        .some(&crc16),
      )
      return .success((vendor, product, version, crc16))
    }
  }
  
  public var name: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickName)
      .map(String.init(cString:))
      .flatMapError { _ in
        self.resultOf(SDL_GetJoystickNameForID)
          .map(String.init(cString:))
      }
  }
  
  public var path: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickPath)
      .map(String.init(cString:))
      .flatMapError { _ in
        self.resultOf(SDL_GetJoystickPathForID)
          .map(String.init(cString:))
      }
  }
  
  public var power: Result<(battery: SDL_PowerState, percent: Int32), SDL_Error> {
    var percent: Int32! = 0
    return self
      .resultOf(SDL_GetJoystickPowerInfo, .some(&percent))
      .flatMap { state in
        switch state {
          case .error: return .failure(.error)
          default: return .success((state, percent))
        }
      }
  }
  
  public var productID: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickProduct)
      .flatMap { _ in
        self.resultOf(SDL_GetJoystickProductForID)
      }
  }
  
  public var productVersion: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickProductVersion)
      .flatMap { _ in
        self.resultOf(SDL_GetJoystickProductVersionForID)
      }
  }
  
  public var properties: Result<SDL_PropertiesID, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickProperties)
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
        guard let cString = SDL_GetJoystickSerial($0)
        else { return .success("") }
        return .success(String(cString: cString))
      }
  }
  
  public var type: Result<SDL_JoystickType, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickType)
      .flatMap { _ in
        self.resultOf(SDL_GetJoystickTypeForID)
      }
  }
  
  public var vendor: Result<UInt16, SDL_Error> {
    self
      .resultOf(SDL_GetJoystickVendor)
      .flatMap { _ in
        self.resultOf(SDL_GetJoystickVendorForID)
      }
  }
  
  public var axes: Result<Range<Int32>, SDL_Error> {
    self
      .resultOf(SDL_GetNumJoystickAxes)
      .map { 0..<$0 }
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
      indices.map { axis in
        (axis, SDL_GetJoystickAxis(pointer, axis))
      }
    }
  }
  
  public var buttons: Result<Range<Int32>, SDL_Error> {
    self
      .resultOf(SDL_GetNumJoystickButtons)
      .map { 0..<$0 }
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
      indices.map { button in
        (button, SDL_GetJoystickButton(pointer, button))
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
    try self(SDL_RumbleJoystick, frequency.lowerBound, frequency.upperBound, milliseconds)
  }
  
  public func triggers<T>(_ frequency: T, duration milliseconds: UInt32) throws(SDL_Error) where T : RangeExpression, T.Bound == UInt16 {
    let frequency = frequency.relative(to: UInt16.min..<UInt16.max)
    try self(SDL_RumbleJoystickTriggers, frequency.lowerBound, frequency.upperBound, milliseconds)
  }
}

extension Joystick {
  // FIXME: Needs better test coverage
  /**
   - seealso: `SDL_AttachVirtualJoystick`
   */
  @discardableResult
  public static func attach(
    name: String
    , type: SDL_JoystickType = .gamepad
    , vendorID: UInt16 = 0
    , productID: UInt16 = 0
    , trackballs: Int32 = 0
    , hats: Int32 = 0
    , buttons: [SDL_GamepadButton] = SDL_GamepadButton.allCases
    , axises: [SDL_GamepadAxis] = SDL_GamepadAxis.allCases
    , touchpads: [SDL_VirtualJoystickTouchpadDesc] = []
    , sensors: [SDL_VirtualJoystickSensorDesc] = []
  ) throws(SDL_Error) -> SDL_JoystickID {
    var desc = SDL_VirtualJoystickDesc(
      /// Why are we setting 'version' to this `sizeOf` value?
      /// See => https://wiki.libsdl.org/SDL3/SDL_INIT_INTERFACE
      version: Uint32(MemoryLayout<SDL_VirtualJoystickDesc>.size)
      , type: UInt16(type.rawValue)
      , padding: .zero
      , vendor_id: vendorID
      , product_id: productID
      , naxes: UInt16(axises.count)
      , nbuttons: UInt16(buttons.count)
      , nballs: UInt16(trackballs)
      , nhats: UInt16(hats)
      , ntouchpads: UInt16(touchpads.count)
      , nsensors: UInt16(sensors.count)
      , padding2: (.zero, .zero)
      , button_mask: UInt32(buttons.reduce(0) { $0 | $1.rawValue })
      , axis_mask: UInt32(axises.reduce(0) { $0 | $1.rawValue })
      , name: name.withCString { $0 }
      , touchpads: touchpads.withUnsafeBufferPointer(\.baseAddress)
      , sensors: sensors.withUnsafeBufferPointer(\.baseAddress)
      , userdata: nil
      , Update: __VirtualJoystick_Update
      , SetPlayerIndex: __VirtualJoystickSetPlayerIndex
      , Rumble: __VirtualJoystickRumble
      , RumbleTriggers: __VirtualJoystickRumbleTriggers
      , SetLED: __VirtualJoystickSetLED
      , SendEffect: __VirtualJoystickSendEffect
      , SetSensorsEnabled: __VirtualJoystickSetSensorsEnabled
      , Cleanup: __VirtualJoystickCleanup
    )
    
    switch SDL_AttachVirtualJoystick(&desc) {
      case 0: throw .error
      case let joystickID: return joystickID
    }
  }
  
  /**
   - seealso: `SDL_DetachVirtualJoystick`
   */
  fileprivate var detach: Result<Joystick, SDL_Error> {
    self.resultOf(SDL_DetachVirtualJoystick)
  }
}

func __VirtualJoystick_Update(_ userData: UnsafeMutableRawPointer?) { }
func __VirtualJoystickSetPlayerIndex(_ userData: UnsafeMutableRawPointer?, playerIndex: Int32) { }
func __VirtualJoystickRumble(_ userData: UnsafeMutableRawPointer?, lowFrequency: Uint16, highFrequency: Uint16) -> Bool { false }
func __VirtualJoystickRumbleTriggers(_ userData: UnsafeMutableRawPointer?, leftRumble: Uint16, rightRumble: Uint16) -> Bool { false }
func __VirtualJoystickSetLED(_ userData: UnsafeMutableRawPointer?, red: UInt8, green: UInt8, blue: UInt8) -> Bool { false }
func __VirtualJoystickSendEffect(_ userData: UnsafeMutableRawPointer?, data: UnsafeRawPointer?, size: Int32) -> Bool { false }
func __VirtualJoystickSetSensorsEnabled(_ userData: UnsafeMutableRawPointer?, enabled: Bool) -> Bool { false }
func __VirtualJoystickCleanup(_ userData: UnsafeMutableRawPointer?) { }

public protocol SDL_Gamepad: SDL_Joystick {
  /*
  SDL_AddGamepadMapping
  SDL_AddGamepadMappingsFromFile
  SDL_AddGamepadMappingsFromIO
  SDL_CloseGamepad
  SDL_GamepadConnected
  SDL_GamepadEventsEnabled
  SDL_GamepadHasAxis
  SDL_GamepadHasButton
  SDL_GamepadHasSensor
  SDL_GamepadSensorEnabled
  SDL_GetGamepadAppleSFSymbolsNameForAxis
  SDL_GetGamepadAppleSFSymbolsNameForButton
  SDL_GetGamepadAxis
  SDL_GetGamepadAxisFromString
  SDL_GetGamepadBindings
  SDL_GetGamepadButton
  SDL_GetGamepadButtonFromString
  SDL_GetGamepadButtonLabel
  SDL_GetGamepadButtonLabelForType
  SDL_GetGamepadConnectionState
  SDL_GetGamepadFirmwareVersion
  SDL_GetGamepadFromID
  SDL_GetGamepadFromPlayerIndex
  SDL_GetGamepadGUIDForID
  SDL_GetGamepadID
  SDL_GetGamepadJoystick
  SDL_GetGamepadMapping
  SDL_GetGamepadMappingForGUID
  SDL_GetGamepadMappingForID
  SDL_GetGamepadMappings
  SDL_GetGamepadName
  SDL_GetGamepadNameForID
  SDL_GetGamepadPath
  SDL_GetGamepadPathForID
  SDL_GetGamepadPlayerIndex
  SDL_GetGamepadPlayerIndexForID
  SDL_GetGamepadPowerInfo
  SDL_GetGamepadProduct
  SDL_GetGamepadProductForID
  SDL_GetGamepadProductVersion
  SDL_GetGamepadProductVersionForID
  SDL_GetGamepadProperties
  SDL_GetGamepads
  SDL_GetGamepadSensorData
  SDL_GetGamepadSensorDataRate
  SDL_GetGamepadSerial
  SDL_GetGamepadSteamHandle
  SDL_GetGamepadStringForAxis
  SDL_GetGamepadStringForButton
  SDL_GetGamepadStringForType
  SDL_GetGamepadTouchpadFinger
  SDL_GetGamepadType
  SDL_GetGamepadTypeForID
  SDL_GetGamepadTypeFromString
  SDL_GetGamepadVendor
  SDL_GetGamepadVendorForID
  SDL_GetNumGamepadTouchpadFingers
  SDL_GetNumGamepadTouchpads
  SDL_GetRealGamepadType
  SDL_GetRealGamepadTypeForID
  SDL_HasGamepad
  SDL_IsGamepad
  SDL_OpenGamepad
  SDL_ReloadGamepadMappings
  SDL_RumbleGamepad
  SDL_RumbleGamepadTriggers
  SDL_SendGamepadEffect
  SDL_SetGamepadEventsEnabled
  SDL_SetGamepadLED
  SDL_SetGamepadMapping
  SDL_SetGamepadPlayerIndex
  SDL_SetGamepadSensorEnabled
  SDL_UpdateGamepads
   */
}
