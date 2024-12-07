public enum SDL_InitFlags: UInt32, CaseIterable, ExpressibleByIntegerLiteral, OptionSet {
  public init(integerLiteral value: UInt32) {
    self.init(rawValue: value)
  }

  public init(rawValue: Uint32) {
    switch rawValue {
      case SDL_INIT_AUDIO:    self = .audio
      case SDL_INIT_VIDEO:    self = .video
      case SDL_INIT_JOYSTICK: self = .joystick
      case SDL_INIT_HAPTIC:   self = .haptic
      case SDL_INIT_GAMEPAD:  self = .gamepad
      case SDL_INIT_EVENTS:   self = .events
      case SDL_INIT_SENSOR:   self = .sensor
      case SDL_INIT_CAMERA:   self = .camera
      default: self = .invalid
    }
  }
  
  case audio
  case video
  case joystick
  case haptic
  case gamepad
  case events
  case sensor
  case camera
  case invalid
  
  public var debugDescription: String {
    switch self {
      case .audio:    return "audio"
      case .video:    return "video"
      case .joystick: return "joystick"
      case .haptic:   return "haptic"
      case .gamepad:  return "gamepad"
      case .events:   return "events"
      case .sensor:   return "sensor"
      case .camera:   return "camera"
      case .invalid:  return "invalid"
    }
  }
  
  public var rawValue: UInt32 {
    switch self {
      case .audio: return SDL_INIT_AUDIO
      case .video: return SDL_INIT_VIDEO
      case .joystick: return SDL_INIT_JOYSTICK
      case .haptic: return SDL_INIT_HAPTIC
      case .gamepad: return SDL_INIT_GAMEPAD
      case .events: return SDL_INIT_EVENTS
      case .sensor: return SDL_INIT_SENSOR
      case .camera: return SDL_INIT_CAMERA
      case .invalid: return 0
    }
  }
  
  public static var allCases: [Self] {
    [
      .audio,
      .video,
      .joystick,
      .haptic,
      .gamepad,
      .events,
      .sensor,
      .camera
    ]
  }
}

public func SDL_Init(_ flags: SDL_InitFlags...) throws(SDL_Error) {
  try SDL_Init(flags)
}

public func SDL_Init(_ flags: [SDL_InitFlags]) throws(SDL_Error) {
  guard SDL_Init(flags.reduce(0) { $0 | $1.rawValue }) else {
    throw .error
  }
}
