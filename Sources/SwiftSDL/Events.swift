extension SDL_Event {
  public var eventType: SDL_EventType {
    SDL_EventType(type)
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

extension SDL_EventType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static var allCases: [SDL_EventType] {
    [
      .firstEvent,
      .quit,
      .terminating,
      .lowMemory,
      .willEnterBackground,
      .didEnterBackground,
      .willEnterForeground,
      .didEnterForeground,
      .localesChanged,
      .systemThemeChanged,
      .displayOrientationChanged,
      .displayAdded,
      .displayRemoved,
      .displayMoved,
      .displayDesktopModeChanged,
      .displayCurrentModeChanged,
      .displayContentScaleChanged,
      .displayFirst,
      .displayLast,
      .windowShown,
      .windowHidden,
      .windowExposed,
      .windowMoved,
      .windowResized,
      .windowPixelSizeChanged,
      .windowMetalViewResized,
      .windowMinimized,
      .windowMaximized,
      .windowRestore,
      .windowMouseEntered,
      .windowMouseLeft,
      .windowFocusGained,
      .windowFocusLost,
      .windowCloseRequested,
      .windowHitTest,
      .windowICCPROFChanged,
      .windowDisplayChanged,
      .windowDisplayScaleChanged,
      .windowSafeAreaChanged,
      .windowOccluded,
      .windowEnteredFullscreen,
      .windowLeftFullscreen,
      .windowDestroyed,
      .windowHDRStateChanged,
      .windowFirst,
      .windowLast,
      .keyDown,
      .keyUp,
      .textEditing,
      .textInput,
      .keymapChanged,
      .keyboardAdded,
      .keyboardRemoved,
      .textEditingCandidates,
      .mouseMotion,
      .mouseButtonDown,
      .mouseButtonUp,
      .mouseWheel,
      .mouseAdded,
      .mouseRemoved,
      .joystickAxisMotion,
      .joystickBallMotion,
      .joystickHatMotion,
      .joystickButtonDown,
      .joystickButtonUp,
      .joystickAdded,
      .joystickRemoved,
      .joystickBatteryUpdated,
      .joystickUpdateComplete,
      .gamepadAxisMotion,
      .gamepadButtonDown,
      .gamepadButtonUp,
      .gamepadAdded,
      .gamepadRemoved,
      .gamepadRemapped,
      .touchpadDown,
      .touchpadMotion,
      .touchpadUp,
      .gamepadSensorUpdate,
      .gamepadUpdateComplete,
      .gamepadSteamHandleUpdated,
      .fingerDown,
      .fingerUp,
      .fingerMotion,
      .clipboardUpdate,
      .dropFile,
      .dropText,
      .dropBegin,
      .dropComplete,
      .dropPosition,
      .audioDeviceAdded,
      .audioDeviceRemoved,
      .audioDeviceFormatChanged,
      .sensorUpdate,
      .penProximityIn,
      .penProximityOut,
      .penDown,
      .penUp,
      .penButtonDown,
      .penButtonUp,
      .penMotion,
      .penAxis,
      .cameraDeviceAdded,
      .cameraDeviceRemoved,
      .cameraDeviceApproved,
      .cameraDeviceDenied,
      .renderTargetsReset,
      .renderDeviceReset,
      .pollSentinel,
      .user,
      .last,
      .padding
    ]
  }
  
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
      case .localesChanged: return "localesChanged"
      case .systemThemeChanged: return "systemThemeChanged"
      case .displayOrientationChanged: return "displayOrientationChanged"
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
      case .windowRestore: return "windowRestore"
      case .windowMouseEntered: return "windowMouseEntered"
      case .windowMouseLeft: return "windowMouseLeft"
      case .windowFocusGained: return "windowFocusGained"
      case .windowFocusLost: return "windowFocusLost"
      case .windowCloseRequested: return "windowCloseRequested"
      case .windowHitTest: return "windowHitTest"
      case .windowICCPROFChanged: return "windowICCPROFChanged"
      case .windowDisplayChanged: return "windowDisplayChanged"
      case .windowDisplayScaleChanged: return "windowDisplayScaleChanged"
      case .windowSafeAreaChanged: return "windowSafeAreaChanged"
      case .windowOccluded: return "windowOccluded"
      case .windowEnteredFullscreen: return "windowEnteredFullscreen"
      case .windowLeftFullscreen: return "windowLeftFullscreen"
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
      case .touchpadDown: return "touchpadDown"
      case .touchpadMotion: return "touchpadMotion"
      case .touchpadUp: return "touchpadUp"
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
      case .sensorUpdate: return "sensorUpdate"
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
      case .last: return "last"
      case .padding: return "padding"
      default: return "unknown event type: \(rawValue)"
    }
  }
  
  public static let firstEvent = SDL_EVENT_FIRST
  public static let quit = SDL_EVENT_QUIT
  public static let terminating = SDL_EVENT_TERMINATING
  public static let lowMemory = SDL_EVENT_LOW_MEMORY
  public static let willEnterBackground = SDL_EVENT_WILL_ENTER_BACKGROUND
  public static let didEnterBackground = SDL_EVENT_DID_ENTER_BACKGROUND
  public static let willEnterForeground = SDL_EVENT_WILL_ENTER_FOREGROUND
  public static let didEnterForeground = SDL_EVENT_DID_ENTER_FOREGROUND
  public static let localesChanged = SDL_EVENT_LOCALE_CHANGED
  public static let systemThemeChanged = SDL_EVENT_SYSTEM_THEME_CHANGED
  public static let displayOrientationChanged = SDL_EVENT_DISPLAY_ORIENTATION
  public static let displayAdded = SDL_EVENT_DISPLAY_ADDED
  public static let displayRemoved = SDL_EVENT_DISPLAY_REMOVED
  public static let displayMoved = SDL_EVENT_DISPLAY_MOVED
  public static let displayDesktopModeChanged = SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED
  public static let displayCurrentModeChanged = SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED
  public static let displayContentScaleChanged = SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED
  public static let displayFirst = SDL_EVENT_DISPLAY_FIRST
  public static let displayLast = SDL_EVENT_DISPLAY_LAST
  public static let windowShown = SDL_EVENT_WINDOW_SHOWN
  public static let windowHidden = SDL_EVENT_WINDOW_HIDDEN
  public static let windowExposed = SDL_EVENT_WINDOW_EXPOSED
  public static let windowMoved = SDL_EVENT_WINDOW_MOVED
  public static let windowResized = SDL_EVENT_WINDOW_RESIZED
  public static let windowPixelSizeChanged = SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED
  public static let windowMetalViewResized = SDL_EVENT_WINDOW_METAL_VIEW_RESIZED
  public static let windowMinimized = SDL_EVENT_WINDOW_MINIMIZED
  public static let windowMaximized = SDL_EVENT_WINDOW_MAXIMIZED
  public static let windowRestore = SDL_EVENT_WINDOW_RESTORED
  public static let windowMouseEntered = SDL_EVENT_WINDOW_MOUSE_ENTER
  public static let windowMouseLeft = SDL_EVENT_WINDOW_MOUSE_LEAVE
  public static let windowFocusGained = SDL_EVENT_WINDOW_FOCUS_GAINED
  public static let windowFocusLost = SDL_EVENT_WINDOW_FOCUS_LOST
  public static let windowCloseRequested = SDL_EVENT_WINDOW_CLOSE_REQUESTED
  public static let windowHitTest = SDL_EVENT_WINDOW_HIT_TEST
  public static let windowICCPROFChanged = SDL_EVENT_WINDOW_ICCPROF_CHANGED
  public static let windowDisplayChanged = SDL_EVENT_WINDOW_DISPLAY_CHANGED
  public static let windowDisplayScaleChanged = SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED
  public static let windowSafeAreaChanged = SDL_EVENT_WINDOW_SAFE_AREA_CHANGED
  public static let windowOccluded = SDL_EVENT_WINDOW_OCCLUDED
  public static let windowEnteredFullscreen = SDL_EVENT_WINDOW_ENTER_FULLSCREEN
  public static let windowLeftFullscreen = SDL_EVENT_WINDOW_LEAVE_FULLSCREEN
  public static let windowDestroyed = SDL_EVENT_WINDOW_DESTROYED
  public static let windowHDRStateChanged = SDL_EVENT_WINDOW_HDR_STATE_CHANGED
  public static let windowFirst = SDL_EVENT_WINDOW_FIRST
  public static let windowLast = SDL_EVENT_WINDOW_LAST
  public static let keyDown = SDL_EVENT_KEY_DOWN
  public static let keyUp = SDL_EVENT_KEY_UP
  public static let textEditing = SDL_EVENT_TEXT_EDITING
  public static let textInput = SDL_EVENT_TEXT_INPUT
  public static let keymapChanged = SDL_EVENT_KEYMAP_CHANGED
  public static let keyboardAdded = SDL_EVENT_KEYBOARD_ADDED
  public static let keyboardRemoved = SDL_EVENT_KEYBOARD_REMOVED
  public static let textEditingCandidates = SDL_EVENT_TEXT_EDITING_CANDIDATES
  public static let mouseMotion = SDL_EVENT_MOUSE_MOTION
  public static let mouseButtonDown = SDL_EVENT_MOUSE_BUTTON_DOWN
  public static let mouseButtonUp = SDL_EVENT_MOUSE_BUTTON_UP
  public static let mouseWheel = SDL_EVENT_MOUSE_WHEEL
  public static let mouseAdded = SDL_EVENT_MOUSE_ADDED
  public static let mouseRemoved = SDL_EVENT_MOUSE_REMOVED
  public static let joystickAxisMotion = SDL_EVENT_JOYSTICK_AXIS_MOTION
  public static let joystickBallMotion = SDL_EVENT_JOYSTICK_BALL_MOTION
  public static let joystickHatMotion = SDL_EVENT_JOYSTICK_HAT_MOTION
  public static let joystickButtonDown = SDL_EVENT_JOYSTICK_BUTTON_DOWN
  public static let joystickButtonUp = SDL_EVENT_JOYSTICK_BUTTON_UP
  public static let joystickAdded = SDL_EVENT_JOYSTICK_ADDED
  public static let joystickRemoved = SDL_EVENT_JOYSTICK_REMOVED
  public static let joystickBatteryUpdated = SDL_EVENT_JOYSTICK_BATTERY_UPDATED
  public static let joystickUpdateComplete = SDL_EVENT_JOYSTICK_UPDATE_COMPLETE
  public static let gamepadAxisMotion = SDL_EVENT_GAMEPAD_AXIS_MOTION
  public static let gamepadButtonDown = SDL_EVENT_GAMEPAD_BUTTON_DOWN
  public static let gamepadButtonUp = SDL_EVENT_GAMEPAD_BUTTON_UP
  public static let gamepadAdded = SDL_EVENT_GAMEPAD_ADDED
  public static let gamepadRemoved = SDL_EVENT_GAMEPAD_REMOVED
  public static let gamepadRemapped = SDL_EVENT_GAMEPAD_REMAPPED
  public static let touchpadDown = SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN
  public static let touchpadMotion = SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION
  public static let touchpadUp = SDL_EVENT_GAMEPAD_TOUCHPAD_UP
  public static let gamepadSensorUpdate = SDL_EVENT_GAMEPAD_SENSOR_UPDATE
  public static let gamepadUpdateComplete = SDL_EVENT_GAMEPAD_UPDATE_COMPLETE
  public static let gamepadSteamHandleUpdated = SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED
  public static let fingerDown = SDL_EVENT_FINGER_DOWN
  public static let fingerUp = SDL_EVENT_FINGER_UP
  public static let fingerMotion = SDL_EVENT_FINGER_MOTION
  public static let clipboardUpdate = SDL_EVENT_CLIPBOARD_UPDATE
  public static let dropFile = SDL_EVENT_DROP_FILE
  public static let dropText = SDL_EVENT_DROP_TEXT
  public static let dropBegin = SDL_EVENT_DROP_BEGIN
  public static let dropComplete = SDL_EVENT_DROP_COMPLETE
  public static let dropPosition = SDL_EVENT_DROP_POSITION
  public static let audioDeviceAdded = SDL_EVENT_AUDIO_DEVICE_ADDED
  public static let audioDeviceRemoved = SDL_EVENT_AUDIO_DEVICE_REMOVED
  public static let audioDeviceFormatChanged = SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED
  public static let sensorUpdate = SDL_EVENT_SENSOR_UPDATE
  public static let penProximityIn = SDL_EVENT_PEN_PROXIMITY_IN
  public static let penProximityOut = SDL_EVENT_PEN_PROXIMITY_OUT
  public static let penDown = SDL_EVENT_PEN_DOWN
  public static let penUp = SDL_EVENT_PEN_UP
  public static let penButtonDown = SDL_EVENT_PEN_BUTTON_DOWN
  public static let penButtonUp = SDL_EVENT_PEN_BUTTON_UP
  public static let penMotion = SDL_EVENT_PEN_MOTION
  public static let penAxis = SDL_EVENT_PEN_AXIS
  public static let cameraDeviceAdded = SDL_EVENT_CAMERA_DEVICE_ADDED
  public static let cameraDeviceRemoved = SDL_EVENT_CAMERA_DEVICE_REMOVED
  public static let cameraDeviceApproved = SDL_EVENT_CAMERA_DEVICE_APPROVED
  public static let cameraDeviceDenied = SDL_EVENT_CAMERA_DEVICE_DENIED
  public static let renderTargetsReset = SDL_EVENT_RENDER_TARGETS_RESET
  public static let renderDeviceReset = SDL_EVENT_RENDER_DEVICE_RESET
  public static let pollSentinel = SDL_EVENT_POLL_SENTINEL
  public static let user = SDL_EVENT_USER
  public static let last = SDL_EVENT_LAST
  public static let padding = SDL_EVENT_ENUM_PADDING
}
