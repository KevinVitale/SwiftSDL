extension SDL_GamepadType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let unknown = SDL_GAMEPAD_TYPE_UNKNOWN
  public static let standard = SDL_GAMEPAD_TYPE_STANDARD
  public static let xbox360 = SDL_GAMEPAD_TYPE_XBOX360
  public static let xboxone = SDL_GAMEPAD_TYPE_XBOXONE
  public static let ps3 = SDL_GAMEPAD_TYPE_PS3
  public static let ps4 = SDL_GAMEPAD_TYPE_PS4
  public static let ps5 = SDL_GAMEPAD_TYPE_PS5
  public static let joyconSwitchPro = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO
  public static let joyconLeft = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT
  public static let joyconRight = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT
  public static let joyconPair = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR
  
  public static var allCases: [SDL_GamepadType] {
    [
      .standard,
      .xbox360,
      .xboxone,
      .ps3,
      .ps4,
      .ps5,
      .joyconSwitchPro,
      .joyconLeft,
      .joyconRight,
      .joyconPair
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case SDL_GAMEPAD_TYPE_UNKNOWN: return "Unknown"
      case SDL_GAMEPAD_TYPE_STANDARD: return "Standard"
      case SDL_GAMEPAD_TYPE_XBOX360: return "Xbox 360"
      case SDL_GAMEPAD_TYPE_XBOXONE: return "Xbox One"
      case SDL_GAMEPAD_TYPE_PS3: return "PS3"
      case SDL_GAMEPAD_TYPE_PS4: return "PS4"
      case SDL_GAMEPAD_TYPE_PS5: return "PS5"
      case SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO: return "Nintendo Switch"
      case SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT: return "Joy-Con (L)"
      case SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT: return "Joy-Con (R)"
      case SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR: return "Joy-Con Pair"
      default: return "Unknown SDL_GamepadType: \(self.rawValue)"
    }
  }
}

extension SDL_GamepadButton: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible, @retroactive Hashable {
  public static let invalid = SDL_GAMEPAD_BUTTON_INVALID
  public static let south = SDL_GAMEPAD_BUTTON_SOUTH
  public static let east = SDL_GAMEPAD_BUTTON_EAST
  public static let west = SDL_GAMEPAD_BUTTON_WEST
  public static let north = SDL_GAMEPAD_BUTTON_NORTH
  public static let back = SDL_GAMEPAD_BUTTON_BACK
  public static let guide = SDL_GAMEPAD_BUTTON_GUIDE
  public static let start = SDL_GAMEPAD_BUTTON_START
  public static let leftStick = SDL_GAMEPAD_BUTTON_LEFT_STICK
  public static let rightStick = SDL_GAMEPAD_BUTTON_RIGHT_STICK
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
      case SDL_GAMEPAD_BUTTON_SOUTH: return "South"
      case SDL_GAMEPAD_BUTTON_EAST: return "East"
      case SDL_GAMEPAD_BUTTON_WEST: return "West"
      case SDL_GAMEPAD_BUTTON_NORTH: return "North"
      case SDL_GAMEPAD_BUTTON_BACK: return "Back"
      case SDL_GAMEPAD_BUTTON_GUIDE: return "Guide"
      case SDL_GAMEPAD_BUTTON_START: return "Start"
      case SDL_GAMEPAD_BUTTON_LEFT_STICK: return "Left Stick"
      case SDL_GAMEPAD_BUTTON_RIGHT_STICK: return "Right Stick"
      case SDL_GAMEPAD_BUTTON_LEFT_SHOULDER: return "Left Shoulder"
      case SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER: return "Right Shoulder"
      case SDL_GAMEPAD_BUTTON_DPAD_UP: return "DPAD Up"
      case SDL_GAMEPAD_BUTTON_DPAD_DOWN: return "DPAD Down"
      case SDL_GAMEPAD_BUTTON_DPAD_LEFT: return "DPAD Left"
      case SDL_GAMEPAD_BUTTON_DPAD_RIGHT: return "DPAD Right"
      case SDL_GAMEPAD_BUTTON_MISC1: return "Misc1"
      case SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1: return "Right Paddle 1"
      case SDL_GAMEPAD_BUTTON_LEFT_PADDLE1: return "Left Paddle 1"
      case SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2: return "Right Paddle 2"
      case SDL_GAMEPAD_BUTTON_LEFT_PADDLE2: return "Left Paddle 2"
      case SDL_GAMEPAD_BUTTON_TOUCHPAD: return "Touchpad"
      case SDL_GAMEPAD_BUTTON_MISC2: return "Misc2"
      case SDL_GAMEPAD_BUTTON_MISC3: return "Misc3"
      case SDL_GAMEPAD_BUTTON_MISC4: return "Misc4"
      case SDL_GAMEPAD_BUTTON_MISC5: return "Misc5"
      case SDL_GAMEPAD_BUTTON_MISC6: return "Misc6"
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
      case SDL_GAMEPAD_AXIS_LEFTY: return "left y"
      case SDL_GAMEPAD_AXIS_RIGHTX: return "right x"
      case SDL_GAMEPAD_AXIS_RIGHTY: return "right y"
      case SDL_GAMEPAD_AXIS_LEFT_TRIGGER: return "left trigger"
      case SDL_GAMEPAD_AXIS_RIGHT_TRIGGER: return "right trigger"
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
