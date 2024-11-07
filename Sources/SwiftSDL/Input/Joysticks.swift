public enum Joysticks {
  public static var connected: Result<[JoystickID], SDL_Error> {
    Result {
      try SDL_BufferPointer(SDL_GetJoysticks).map {
        JoystickID.connected($0)
      }
    }
    .mapError { $0 as! SDL_Error }
  }
  
  @discardableResult
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
