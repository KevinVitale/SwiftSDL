public enum Gamepads {
  public static var connected: Result<[JoystickID], SDL_Error> {
    Result {
      try SDL_BufferPointer(SDL_GetGamepads).map {
        JoystickID.connected($0)
      }
    }
    .mapError { $0 as! SDL_Error }
  }
}

extension SDL_GamepadButton: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let invalid = SDL_GAMEPAD_BUTTON_INVALID
  public static let south = SDL_GAMEPAD_BUTTON_SOUTH
  public static let east = SDL_GAMEPAD_BUTTON_EAST
  public static let west = SDL_GAMEPAD_BUTTON_WEST
  public static let north = SDL_GAMEPAD_BUTTON_NORTH
  public static let back = SDL_GAMEPAD_BUTTON_BACK
  public static let guide = SDL_GAMEPAD_BUTTON_GUIDE
  public static let start = SDL_GAMEPAD_BUTTON_START
  public static let leftStick = SDL_GAMEPAD_BUTTON_LEFT_STICK
  public static let rightSitck = SDL_GAMEPAD_BUTTON_RIGHT_STICK
  public static let leftShoulder = SDL_GAMEPAD_BUTTON_LEFT_SHOULDER
  public static let rightShoulder = SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER
  public static let up = SDL_GAMEPAD_BUTTON_DPAD_UP
  public static let down = SDL_GAMEPAD_BUTTON_DPAD_DOWN
  public static let left = SDL_GAMEPAD_BUTTON_DPAD_LEFT
  public static let right = SDL_GAMEPAD_BUTTON_DPAD_RIGHT
  public static let misc1 = SDL_GAMEPAD_BUTTON_MISC1
  public static let rightPaddle1 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1
  public static let leftPaddle1 = SDL_GAMEPAD_BUTTON_LEFT_PADDLE1
  public static let rightPaddle2 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2
  public static let leftPaddle2 = SDL_GAMEPAD_BUTTON_LEFT_PADDLE2
  public static let touchpad = SDL_GAMEPAD_BUTTON_TOUCHPAD
  public static let misc2 = SDL_GAMEPAD_BUTTON_MISC2
  public static let misc3 = SDL_GAMEPAD_BUTTON_MISC3
  public static let misc4 = SDL_GAMEPAD_BUTTON_MISC4
  public static let misc5 = SDL_GAMEPAD_BUTTON_MISC5
  public static let misc6 = SDL_GAMEPAD_BUTTON_MISC6
  public static let count = SDL_GAMEPAD_AXIS_COUNT

  public var debugDescription: String {
    switch self {
      case SDL_GAMEPAD_BUTTON_INVALID: return "invalid"
      case SDL_GAMEPAD_BUTTON_SOUTH: return "south"
      case SDL_GAMEPAD_BUTTON_EAST: return "east"
      case SDL_GAMEPAD_BUTTON_WEST: return "west"
      case SDL_GAMEPAD_BUTTON_NORTH: return "north"
      case SDL_GAMEPAD_BUTTON_BACK: return "back"
      case SDL_GAMEPAD_BUTTON_GUIDE: return "guide"
      case SDL_GAMEPAD_BUTTON_START: return "start"
      case SDL_GAMEPAD_BUTTON_LEFT_STICK: return "left stick"
      case SDL_GAMEPAD_BUTTON_RIGHT_STICK: return "right stick"
      case SDL_GAMEPAD_BUTTON_LEFT_SHOULDER: return "left shoulder"
      case SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER: return "right shoulder"
      case SDL_GAMEPAD_BUTTON_DPAD_UP: return "up"
      case SDL_GAMEPAD_BUTTON_DPAD_DOWN: return "down"
      case SDL_GAMEPAD_BUTTON_DPAD_LEFT: return "left"
      case SDL_GAMEPAD_BUTTON_DPAD_RIGHT: return "right"
      case SDL_GAMEPAD_BUTTON_MISC1: return "misc (1)"
      case SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1: return "right paddle (1)"
      case SDL_GAMEPAD_BUTTON_LEFT_PADDLE1: return "left paddle (1)"
      case SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2: return "right paddle (2)"
      case SDL_GAMEPAD_BUTTON_LEFT_PADDLE2: return "left paddle (2)"
      case SDL_GAMEPAD_BUTTON_TOUCHPAD: return "touchpad"
      case SDL_GAMEPAD_BUTTON_MISC2: return "misc (2)"
      case SDL_GAMEPAD_BUTTON_MISC3: return "misc (3)"
      case SDL_GAMEPAD_BUTTON_MISC4: return "misc (4)"
      case SDL_GAMEPAD_BUTTON_MISC5: return "misc (5)"
      case SDL_GAMEPAD_BUTTON_MISC6: return "misc (6)"
      case SDL_GAMEPAD_BUTTON_COUNT: return "\(SDL_GAMEPAD_BUTTON_COUNT.rawValue)"
      default: return "Unknown SDL_GamepadButton: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_GamepadButton] {
    [
      // SDL_GAMEPAD_BUTTON_INVALID,
      SDL_GAMEPAD_BUTTON_SOUTH,
      SDL_GAMEPAD_BUTTON_EAST,
      SDL_GAMEPAD_BUTTON_WEST,
      SDL_GAMEPAD_BUTTON_NORTH,
      SDL_GAMEPAD_BUTTON_BACK,
      SDL_GAMEPAD_BUTTON_GUIDE,
      SDL_GAMEPAD_BUTTON_START,
      SDL_GAMEPAD_BUTTON_LEFT_STICK,
      SDL_GAMEPAD_BUTTON_RIGHT_STICK,
      SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
      SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
      SDL_GAMEPAD_BUTTON_DPAD_UP,
      SDL_GAMEPAD_BUTTON_DPAD_DOWN,
      SDL_GAMEPAD_BUTTON_DPAD_LEFT,
      SDL_GAMEPAD_BUTTON_DPAD_RIGHT,
      SDL_GAMEPAD_BUTTON_MISC1,
      SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,
      SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,
      SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,
      SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,
      SDL_GAMEPAD_BUTTON_TOUCHPAD,
      SDL_GAMEPAD_BUTTON_MISC2,
      SDL_GAMEPAD_BUTTON_MISC3,
      SDL_GAMEPAD_BUTTON_MISC4,
      SDL_GAMEPAD_BUTTON_MISC5,
      SDL_GAMEPAD_BUTTON_MISC6,
      // SDL_GAMEPAD_BUTTON_COUNT
    ]
  }
}

extension SDL_GamepadButtonLabel: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let unknown = SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN
  public static let a = SDL_GAMEPAD_BUTTON_LABEL_A
  public static let b = SDL_GAMEPAD_BUTTON_LABEL_B
  public static let x = SDL_GAMEPAD_BUTTON_LABEL_X
  public static let y = SDL_GAMEPAD_BUTTON_LABEL_Y
  public static let cross = SDL_GAMEPAD_BUTTON_LABEL_CROSS
  public static let circle = SDL_GAMEPAD_BUTTON_LABEL_CIRCLE
  public static let square = SDL_GAMEPAD_BUTTON_LABEL_SQUARE
  public static let triangle = SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE
  
  public var debugDescription: String {
    switch self {
      case SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN: return "unknown"
      case SDL_GAMEPAD_BUTTON_LABEL_A: return "a"
      case SDL_GAMEPAD_BUTTON_LABEL_B: return "b"
      case SDL_GAMEPAD_BUTTON_LABEL_X: return "x"
      case SDL_GAMEPAD_BUTTON_LABEL_Y: return "y"
      case SDL_GAMEPAD_BUTTON_LABEL_CROSS: return "cross"
      case SDL_GAMEPAD_BUTTON_LABEL_CIRCLE: return "circle"
      case SDL_GAMEPAD_BUTTON_LABEL_SQUARE: return "square"
      case SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE: return "triangle"
      default: return "Unknown SDL_GamepadButtonLabel: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_GamepadButtonLabel] {
    [
      SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN,
      SDL_GAMEPAD_BUTTON_LABEL_A,
      SDL_GAMEPAD_BUTTON_LABEL_B,
      SDL_GAMEPAD_BUTTON_LABEL_X,
      SDL_GAMEPAD_BUTTON_LABEL_Y,
      SDL_GAMEPAD_BUTTON_LABEL_CROSS,
      SDL_GAMEPAD_BUTTON_LABEL_CIRCLE,
      SDL_GAMEPAD_BUTTON_LABEL_SQUARE,
      SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE
    ]
  }
}

extension SDL_GamepadAxis: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let invalid = SDL_GAMEPAD_AXIS_INVALID
  public static let leftX = SDL_GAMEPAD_AXIS_LEFTX
  public static let leftY = SDL_GAMEPAD_AXIS_LEFTY
  public static let rightX = SDL_GAMEPAD_AXIS_RIGHTX
  public static let rightY = SDL_GAMEPAD_AXIS_RIGHTY
  public static let leftTrigger = SDL_GAMEPAD_AXIS_LEFT_TRIGGER
  public static let rightTrigger = SDL_GAMEPAD_AXIS_RIGHT_TRIGGER
  public static let count = SDL_GAMEPAD_AXIS_COUNT

  public var debugDescription: String {
    switch self {
      case SDL_GAMEPAD_AXIS_INVALID: return "invalid"
      case SDL_GAMEPAD_AXIS_LEFTX: return "left x"
      case SDL_GAMEPAD_AXIS_LEFTY: return ""
      case SDL_GAMEPAD_AXIS_RIGHTX: return ""
      case SDL_GAMEPAD_AXIS_RIGHTY: return ""
      case SDL_GAMEPAD_AXIS_LEFT_TRIGGER: return ""
      case SDL_GAMEPAD_AXIS_RIGHT_TRIGGER: return ""
      case SDL_GAMEPAD_AXIS_COUNT: return "\(SDL_GAMEPAD_AXIS_COUNT.rawValue)"
      default: return "Unknown SDL_GamepadAxis: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_GamepadAxis] {
    [
      // SDL_GAMEPAD_AXIS_INVALID,
      SDL_GAMEPAD_AXIS_LEFTX,
      SDL_GAMEPAD_AXIS_LEFTY,
      SDL_GAMEPAD_AXIS_RIGHTX,
      SDL_GAMEPAD_AXIS_RIGHTY,
      SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
      SDL_GAMEPAD_AXIS_RIGHT_TRIGGER,
      // SDL_GAMEPAD_AXIS_COUNT
    ]
  }
}

extension SDL_GamepadBindingType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let none = SDL_GAMEPAD_BINDTYPE_NONE
  public static let button = SDL_GAMEPAD_BINDTYPE_BUTTON
  public static let axis = SDL_GAMEPAD_BINDTYPE_AXIS
  public static let hat = SDL_GAMEPAD_BINDTYPE_HAT
  
  public var debugDescription: String {
    switch self {
      case .none: return "none"
      case .button: return "button"
      case .axis: return "axis"
      case .hat: return "hat"
      default: return "Unknown SDL_GamepadBindingType: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_GamepadBindingType] {
    [
      SDL_GAMEPAD_BINDTYPE_NONE,
      SDL_GAMEPAD_BINDTYPE_BUTTON,
      SDL_GAMEPAD_BINDTYPE_AXIS,
      SDL_GAMEPAD_BINDTYPE_HAT
    ]
  }
}
