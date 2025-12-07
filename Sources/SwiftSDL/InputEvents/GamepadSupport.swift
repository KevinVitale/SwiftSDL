extension SDL_GamepadType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static var allCases: [SDL_GamepadType] {
    [
      .standard,
      .xbox360,
      .xboxOne,
      .ps3,
      .ps4,
      .ps5,
      .switchPro,
      .joyconLeft,
      .joyconRight,
      .joyconPair
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .unknown: return "Unknown"
      case .standard: return "Standard"
      case .xbox360: return "Xbox 360"
      case .xboxOne: return "Xbox One"
      case .ps3: return "PS3"
      case .ps4: return "PS4"
      case .ps5: return "PS5"
      case .switchPro: return "Nintendo Switch Pro"
      case .joyconLeft: return "Joy-Con (L)"
      case .joyconRight: return "Joy-Con (R)"
      case .joyconPair: return "Joy-Con Pair"
      case .typeCount: return "Type Count"
      @unknown default: return "Unknown"
    }
  }
}

extension SDL_GamepadButton: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible, @retroactive Hashable, @retroactive Comparable, @retroactive Strideable {
  public typealias Stride = RawValue
  
  public var debugDescription: String {
    switch self {
      case .invalid: return "Invalid Button"
      case .south: return "South"
      case .east: return "East"
      case .west: return "West"
      case .north: return "North"
      case .back: return "Back"
      case .guide: return "Guide"
      case .start: return "Start"
      case .leftStick: return "Left Stick"
      case .rightStick: return "Right Stick"
      case .leftShoulder: return "Left Shoulder"
      case .rightShoulder: return "Right Shoulder"
      case .up: return "DPAD Up"
      case .down: return "DPAD Down"
      case .left: return "DPAD Left"
      case .right: return "DPAD Right"
      case .misc1: return "Misc1"
      case .rightPaddle1: return "Right Paddle 1"
      case .leftPaddle1: return "Left Paddle 1"
      case .rightPaddle2: return "Right Paddle 2"
      case .leftPaddle2: return "Left Paddle 2"
      case .touchpad: return "Touchpad"
      case .misc2: return "Misc2"
      case .misc3: return "Misc3"
      case .misc4: return "Misc4"
      case .misc5: return "Misc5"
      case .misc6: return "Misc6"
      case .buttonCount: return "Button Count"
      @unknown default: return "Invalid Button"
    }
  }
  
  public static var allCases: [SDL_GamepadButton] {
    [
      .south,
      .east,
      .west,
      .north,
      .back,
      .guide,
      .start,
      .leftStick,
      .rightStick,
      .leftShoulder,
      .rightShoulder,
      .misc1,
      .up,
      .down,
      .right,
      .left,
      .rightPaddle1,
      .leftPaddle1,
      .rightPaddle2,
      .leftPaddle2,
      .touchpad,
      .misc2,
      .misc3,
      .misc4,
      .misc5,
      .misc6
    ]
  }
  
  public static func < (lhs: SDL_GamepadButton, rhs: SDL_GamepadButton) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
  
  public func advanced(by n: RawValue) -> SDL_GamepadButton {
    let rawValue = rawValue.advanced(by: Int(n))
    return Self(rawValue: Int32(rawValue)) ?? .invalid
  }
  
  public func distance(to other: SDL_GamepadButton) -> RawValue {
    let distanceTo = Int32(rawValue.distance(to: other.rawValue))
    return distanceTo
  }
}


extension SDL_GamepadButtonLabel: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .unknown: return "unknown"
      case .a: return "a"
      case .b: return "b"
      case .x: return "x"
      case .y: return "y"
      case .cross: return "cross"
      case .circle: return "circle"
      case .square: return "square"
      case .triangle: return "triangle"
      @unknown default: return "unknown"
    }
  }
  
  public static var allCases: [SDL_GamepadButtonLabel] {
    [
      .unknown,
      .a,
      .b,
      .x,
      .y,
      .cross,
      .circle,
      .square,
      .triangle
    ]
  }
}

extension SDL_GamepadAxis: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .invalid: return "invalid"
      case .leftX: return "left x"
      case .leftY: return "left y"
      case .rightX: return "right x"
      case .rightY: return "right y"
      case .leftTrigger: return "left trigger"
      case .rightTrigger: return "right trigger"
      case .axisCount: return "\(Self.axisCount.rawValue)"
      default: return "Unknown SDL_GamepadAxis: \(self.rawValue)"
    }
  }
  
  public static var allCases: [SDL_GamepadAxis] {
    [
      .leftX,
      .leftY,
      .rightX,
      .rightY,
      .leftTrigger,
      .rightTrigger,
    ]
  }
}

extension SDL_GamepadBindingType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
      case .none: return "none"
      case .button: return "button"
      case .axis: return "axis"
      case .hat: return "hat"
      @unknown default: return "none"
    }
  }
  
  public static var allCases: [SDL_GamepadBindingType] {
    [
      .none,
      .button,
      .axis,
      .hat
    ]
  }
}
