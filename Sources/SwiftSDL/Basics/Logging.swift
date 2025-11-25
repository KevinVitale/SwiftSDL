public struct SDL_LogLevel: Sendable {
  public let category: SDL_LogCategory
  public let priority: SDL_LogPriority
  
  public static func category(_ category: SDL_LogCategory, priority: SDL_LogPriority) -> Self {
    Self(category: category, priority: priority)
  }
  
  /// Category: `.application`; Priority: `.info`.
  public static let `default` = category(.application, priority: .info)
}

public func SDL_SetLogLevel(_ level: SDL_LogLevel) {
  SDL_SetLogPriority(Int32(level.category.rawValue), level.priority);
}

public func SDL_Log<T>(level: SDL_LogLevel = .default, _ fmt: T, _ args: CVarArg...) {
  withVaList(args) { __SDL_LogMessageV(Int32(level.category.rawValue), level.priority, String(describing: fmt), $0) }
}
