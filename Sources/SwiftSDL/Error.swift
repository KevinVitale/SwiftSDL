import class Foundation.Thread

public enum SDL_Error: Error, CustomDebugStringConvertible, @unchecked Sendable {
  case error
  case custom(String)
  case customWithArgs(String, [CVarArg])
  
  static var callStackDescription: String {
    Thread.callStackSymbols.joined(separator: "\n")
  }
  
  public var debugDescription: String {
    if case(.custom(let fmt)) = self {
      _ = withVaList([]) { SDL_SetErrorV(fmt, $0) }
    }
    else if case(.customWithArgs(let fmt, let args)) = self {
      _ = withVaList(args) { SDL_SetErrorV(fmt, $0) }
    }
    
    return String(cString: SDL_GetError())
  }
  
  public static func clear() {
    SDL_ClearError()
  }
}
