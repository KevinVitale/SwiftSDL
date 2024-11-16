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
  }
  
  internal init(
    version: Int = MemoryLayout<Self>.size,
    type: SDL_JoystickType,
    vendorID: UInt16,
    productID: UInt16,
    ballsCount: Int32,
    hatsCount: Int32,
    buttons: [SDL_GamepadButton],
    axises: [SDL_GamepadAxis],
    name: UnsafePointer<CChar>,
    touchpads: [SDL_VirtualJoystickTouchpadDesc],
    sensors: [SDL_VirtualJoystickSensorDesc],
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
    let touchpads = touchpads
    let sensors = sensors
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
      name: withUnsafePointer(to: name, \.pointee),
      touchpads: touchpads.withUnsafeBufferPointer(\.baseAddress),
      sensors: sensors.withUnsafeBufferPointer(\.baseAddress),
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
