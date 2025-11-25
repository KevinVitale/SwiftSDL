import class Foundation.Thread

public enum SDL_Error: Error, CustomDebugStringConvertible, @unchecked Sendable {
  /// Retrieve a message about the last error that occurred on the current thread.
  /// - note: Replaces `SDL_GetError`.
  case error
  
  /// Set the SDL error message for the current thread.
  /// - note: Replaces `SDL_SetErrorV`.
  case custom(_ message: String)
  
  /// Set the SDL error message for the current thread.
  /// - note: Replaces `SDL_SetErrorV`.
  case customWithArgs(_ fmt: String, _ args: [CVarArg])
  
  public var debugDescription: String {
    if case(.custom(let fmt)) = self {
      _ = withVaList([]) { __SDL_SetErrorV(fmt, $0) }
    }
    else if case(.customWithArgs(let fmt, let args)) = self {
      _ = withVaList(args) { __SDL_SetErrorV(fmt, $0) }
    }
    
    return String(cString: __SDL_GetError())
  }
  
  /// Clear any previous error message for this thread.
  /// - note: Replaces `SDL_ClearError`.
  public static func clear() {
    __SDL_ClearError()
  }
  
  @available(*, deprecated)
  internal static var callStackDescription: String {
    Thread.callStackSymbols.joined(separator: "\n")
  }
}
