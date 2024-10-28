public struct SDL_Version: RawRepresentable, CustomDebugStringConvertible, @unchecked Sendable {
  public init(rawValue: Int32 = SDL_GetVersion()) {
    self.rawValue = rawValue
  }
  
  public init(
    _ major: Int32,
    _ minor: Int32,
    _ micro: Int32
  ) {
    self.init(rawValue: ((major) * 1000000 + (minor) * 1000 + (micro)))
  }
  
  public var major: Int32 { rawValue / 1000000 }
  public var minor: Int32 { (rawValue / 1000) % 1000 }
  public var micro: Int32 { rawValue % 1000 }
  
  public let rawValue: Int32
  
  public var debugDescription: String {
    "\(major).\(minor).\(micro)"
  }
  
  public func at(least version: SDL_Version) -> Bool {
    version.rawValue >= self.rawValue
  }
  
  public static let current: Self = .init(rawValue: SDL_GetVersion())
}
