import class Foundation.Thread

public enum SDL_Error: Error, CustomDebugStringConvertible {
  case error
  
  static var callStackDescription: String {
    Thread.callStackSymbols.joined(separator: "\n")
  }

  public var debugDescription: String {
    String(cString: SDL_GetError())
  }
  
  public func clear() {
    SDL_ClearError()
  }
}
