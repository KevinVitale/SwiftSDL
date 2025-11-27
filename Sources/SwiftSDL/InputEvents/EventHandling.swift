extension SDL_EventType: @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .firstEvent: return "firstEvent"
      case .quit: return "quit"
      case .terminating: return "terminating"
      case .lowMemory: return "lowMemory"
      case .willEnterBackground:  return "willEnterBackground"
      case .didEnterBackground:  return "didEnterBackground"
      case .willEnterForeground: return "willEnterForeground"
      case .didEnterForeground: return "didEnterForeground"
      case .localeChanged: return "localeChanged"
      case .systemThemeChanged: return "systemThemeChanged"
      case .displayOrientation: return "displayOrientation"
      case .displayAdded: return "displayAdded"
      case .displayRemoved: return "displayRemoved"
      case .displayMoved: return "displayMoved"
      case .displayDesktopModeChanged: return "displayDesktopModeChanged"
      case .displayCurrentModeChanged: return "displayCurrentModeChanged"
      case .displayContentScaleChanged: return "displayContentScaleChanged"
      case .displayFirst: return "displayFirst"
      case .displayLast: return "displayLast"
      case .windowShown: return "windowShown"
      case .windowHidden: return "windowHidden"
      case .windowExposed: return "windowExposed"
      case .windowMoved: return "windowMoved"
      case .windowResized: return "windowResized"
      case .windowPixelSizeChanged: return "windowPixelSizeChanged"
      case .windowMetalViewResized: return "windowMetalViewResized"
      case .windowMinimized: return "windowMinimized"
      case .windowMaximized: return "windowMaximized"
      case .windowRestored: return "windowRestored"
      case .windowMouseEnter: return "windowMouseEnter"
      case .windowMouseLeave: return "windowMouseLeave"
      case .windowFocusGained: return "windowFocusGained"
      case .windowFocusLost: return "windowFocusLost"
      case .windowCloseRequested: return "windowCloseRequested"
      case .windowHitTest: return "windowHitTest"
      case .windowICCProfileChanged: return "windowICCProfileChanged"
      case .windowDisplayChanged: return "windowDisplayChanged"
      case .windowDisplayScaleChanged: return "windowDisplayScaleChanged"
      case .windowSafeAreaChanged: return "windowSafeAreaChanged"
      case .windowOccluded: return "windowOccluded"
      case .windowEnterFullscreen: return "windowEnterFullscreen"
      case .windowLeaveFullscreen: return "windowLeaveFullscreen"
      case .windowDestroyed: return "windowDestroyed"
      case .windowHDRStateChanged: return "windowHDRStateChanged"
      case .windowFirst: return "windowFirst"
      case .windowLast: return "windowLast"
      case .keyDown: return "keyDown"
      case .keyUp: return "keyUp"
      case .textEditing: return "textEditing"
      case .textInput: return "textInput"
      case .keymapChanged: return "keymapChanged"
      case .keyboardAdded: return "keyboardAdded"
      case .keyboardRemoved: return "keyboardRemoved"
      case .textEditingCandidates: return "textEditingCandidates"
      case .mouseMotion: return "mouseMove"
      case .mouseButtonDown: return "mouseButtonDown"
      case .mouseButtonUp: return "mouseButtonUp"
      case .mouseWheel: return "mouseWheel"
      case .mouseAdded: return "mouseAdded"
      case .mouseRemoved: return "mouseRemoved"
      case .joystickAxisMotion: return "joystickAxisMotion"
      case .joystickBallMotion: return "joystickBallMotion"
      case .joystickHatMotion: return "joystickHatMotion"
      case .joystickButtonDown: return "joystickButtonDown"
      case .joystickButtonUp: return "joystickButtonUp"
      case .joystickAdded: return "joystickAdded"
      case .joystickRemoved: return "joystickRemoved"
      case .joystickBatteryUpdated: return "joystickBatteryUpdated"
      case .joystickUpdateComplete: return "joystickUpdateComplete"
      case .gamepadAxisMotion: return "gamepadAxisMotion"
      case .gamepadButtonDown: return "gamepadButtonDown"
      case .gamepadButtonUp: return "gamepadButtonUp"
      case .gamepadAdded: return "gamepadAdded"
      case .gamepadRemoved: return "gamepadRemoved"
      case .gamepadRemapped: return "gamepadRemapped"
      case .gamepadTouchpadDown: return "gamepadTouchpadDown"
      case .gamepadTouchpadMotion: return "gamepadTouchpadMotion"
      case .gamepadTouchpadUp: return "gamepadTouchpadUp"
      case .gamepadSensorUpdate: return "gamepadSensorUpdate"
      case .gamepadUpdateComplete: return "gamepadUpdateComplete"
      case .gamepadSteamHandleUpdated: return "gamepadSteamHandleUpdated"
      case .fingerDown: return "fingerDown"
      case .fingerUp: return "fingerUp"
      case .fingerMotion: return "fingerMotion"
      case .clipboardUpdate: return "clipboardUpdate"
      case .dropFile: return "dropFile"
      case .dropText: return "dropText"
      case .dropBegin: return "dropBegin"
      case .dropComplete: return "dropComplete"
      case .dropPosition: return "dropPosition"
      case .audioDeviceAdded: return "audioDeviceAdded"
      case .audioDeviceRemoved: return "audioDeviceRemoved"
      case .audioDeviceFormatChanged: return "audioDeviceFormatChanged"
      case .penProximityIn: return "penProximityIn"
      case .penProximityOut: return "penProximityOut"
      case .penDown: return "penDown"
      case .penUp: return "penUp"
      case .penButtonDown: return "penButtonDown"
      case .penButtonUp: return "penButtonUp"
      case .penMotion: return "penMotion"
      case .penAxis: return "penAxis"
      case .cameraDeviceAdded: return "cameraDeviceAdded"
      case .cameraDeviceRemoved: return "cameraDeviceRemoved"
      case .cameraDeviceApproved: return "cameraDeviceApproved"
      case .cameraDeviceDenied: return "cameraDeviceDenied"
      case .renderTargetsReset: return "renderTargetsReset"
      case .renderDeviceReset: return "renderDeviceReset"
      case .pollSentinel: return "pollSentinel"
      case .user: return "user"
      case .lastEvent: return "lastEvent"
      case .EVENT_ENUM_PADDING: return "padding"
      default: return "unknown event type: \(rawValue)"
    }
  }
}

extension SDL_Event {
  public var eventType: SDL_EventType {
    SDL_EventType(rawValue: type)!
  }
}

public func pollEvent() throws -> SDL_Event {
  var event = SDL_Event()
  while(SDL_PollEvent(&event)) {
    return event
  }
  return event
}

public func waitEvent() throws -> SDL_Event {
  var event = SDL_Event()
  if(SDL_WaitEvent(&event)) {
    return event
  }
  return event
}

extension SDL_KeyboardEvent {
  public static func == (lhs: Self, rhs: SDL_Keycode) -> Bool {
    lhs.key == rhs
  }
  
  public static func ~= (lhs: SDL_Keycode, rhs: Self) -> Bool {
    lhs == rhs.key
  }
}

extension SDL_MouseButtonEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
}

extension SDL_MouseMotionEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
  
  public func relative<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(xrel), y: Int32(yrel)).to(type)
  }
  
  public func relative<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(xrel), y: Float(yrel)).to(type)
  }
}

extension SDL_TouchFingerEvent {
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: FixedWidthInteger {
    Point(x: Int32(x), y: Int32(y)).to(type)
  }
  
  public func position<S: SIMDScalar>(as type: S.Type) -> SIMD2<S> where S: BinaryFloatingPoint {
    Point(x: Float(x), y: Float(y)).to(type)
  }
}
