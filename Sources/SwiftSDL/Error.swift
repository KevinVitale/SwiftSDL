import class Foundation.Thread

public enum SDL_Error: Error, CustomDebugStringConvertible {
  case error
  
  static var callStackDescription: String {
    Thread.callStackSymbols.joined(separator: "\n")
  }
  
  static public func set(throwing fmt: String, _ args: CVarArg...) throws(SDL_Error) {
    _ = withVaList(args) { SDL_SetErrorV(fmt, $0) }
    throw .error
  }
  
  public var debugDescription: String {
    String(cString: SDL_GetError())
  }
  
  public static func clear() {
    SDL_ClearError()
  }
}
