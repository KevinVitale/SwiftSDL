import class Foundation.Thread

public enum SDL_Error: Error, CustomDebugStringConvertible, @unchecked Sendable {
  case error
  case custom(_ message: String)
  case customWithArgs(_ fmt: String, _ args: [CVarArg])
  
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

  /// Wraps a foreign (non-SDL) error so it can propagate through
  /// `throws(SDL_Error)` APIs. SDL errors pass through unchanged.
  ///
  /// The description's '%' characters are escaped because `SDL_SetErrorV`
  /// treats the message as a printf format string. (Not `customWithArgs`
  /// with "%s": Swift's String CVarArg encodes an NSString pointer for
  /// '%@', which C's '%s' would misread.)
  public static func wrap(_ error: any Error) -> SDL_Error {
    if let error = error as? SDL_Error {
      return error
    }
    let description = String(describing: error)
      .split(separator: "%", omittingEmptySubsequences: false)
      .joined(separator: "%%")
    return .custom(description)
  }
}
