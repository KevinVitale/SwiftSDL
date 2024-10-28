public struct SDLMessageBoxFlag: OptionSet, CaseIterable, CustomDebugStringConvertible, Sendable {
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  public let rawValue: UInt32
  
  public var debugDescription: String {
    switch self {
      case .buttonsLeftToRight: return "leftToRight"
      case .buttonsRightToLeft: return "rightToLeft"
      case .error: return "error"
      case .information: return "information"
      case .warning: return "warning"
      default: return "Unknown SDL_MessageBoxFlag: \(self)"
    }
  }
  
  public static let error = Self(rawValue: SDL_MESSAGEBOX_ERROR)
  public static let warning = Self(rawValue: SDL_MESSAGEBOX_WARNING)
  public static let information = Self(rawValue: SDL_MESSAGEBOX_INFORMATION)
  public static let buttonsLeftToRight = Self(rawValue: SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT)
  public static let buttonsRightToLeft = Self(rawValue: SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT)
  
  public static var allCases: [Self] {
    [
      .buttonsLeftToRight,
      .buttonsRightToLeft,
      .error,
      .information,
      .warning
    ]
  }
}
