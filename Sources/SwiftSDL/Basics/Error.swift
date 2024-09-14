public enum SDL_Error: Error, CustomDebugStringConvertible {
  case error
  
  public var debugDescription: String {
    String(cString: SDL_GetError())
  }
  
  public func clear() {
    SDL_ClearError()
  }
}
