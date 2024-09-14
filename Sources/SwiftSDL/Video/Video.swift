extension SDL_FlipMode: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let none = SDL_FLIP_NONE
  public static let horizontal = SDL_FLIP_HORIZONTAL
  public static let vertical = SDL_FLIP_VERTICAL
  
  public static var allCases: [Self] {
    [
      .none,
      .horizontal,
      .vertical
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .none: return "none"
      case .horizontal: return "horizontal"
      case .vertical: return "vertical"
      default: return "Unknown SDL_FlipMode: \(self)"
    }
  }
}

