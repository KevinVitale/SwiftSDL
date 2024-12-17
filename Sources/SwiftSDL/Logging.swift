extension SDL_LogPriority: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let invalid  = SDL_LOG_PRIORITY_INVALID
  public static let trace    = SDL_LOG_PRIORITY_TRACE
  public static let verbose  = SDL_LOG_PRIORITY_TRACE
  public static let debug    = SDL_LOG_PRIORITY_DEBUG
  public static let info     = SDL_LOG_PRIORITY_INFO
  public static let warn     = SDL_LOG_PRIORITY_WARN
  public static let error    = SDL_LOG_PRIORITY_ERROR
  public static let critical = SDL_LOG_PRIORITY_CRITICAL
  
  public static var allCases: [Self] {
    [
      .trace
      , .verbose
      , .debug
      , .info
      , .warn
      , .error
      , .critical
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .invalid   : return "invalid"
      case .trace     : return "trace"
      case .verbose   : return "verbose"
      case .debug     : return "debug"
      case .info      : return "info"
      case .warn      : return "warn"
      case .error     : return "error"
      case .critical  : return "critical"
      default: return "Unknown SDL_LogPriority: \(self)"
    }
  }
}

extension SDL_LogCategory: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let app     = SDL_LOG_CATEGORY_APPLICATION
  public static let error   = SDL_LOG_CATEGORY_ERROR
  public static let assert  = SDL_LOG_CATEGORY_ASSERT
  public static let system  = SDL_LOG_CATEGORY_SYSTEM
  public static let audio   = SDL_LOG_CATEGORY_AUDIO
  public static let video   = SDL_LOG_CATEGORY_VIDEO
  public static let render  = SDL_LOG_CATEGORY_RENDER
  public static let input   = SDL_LOG_CATEGORY_INPUT
  public static let test    = SDL_LOG_CATEGORY_TEST
  public static let gpu     = SDL_LOG_CATEGORY_GPU
  
  public static let reserved02 = SDL_LOG_CATEGORY_RESERVED2
  public static let reserved03 = SDL_LOG_CATEGORY_RESERVED3
  public static let reserved04 = SDL_LOG_CATEGORY_RESERVED4
  public static let reserved05 = SDL_LOG_CATEGORY_RESERVED5
  public static let reserved06 = SDL_LOG_CATEGORY_RESERVED6
  public static let reserved07 = SDL_LOG_CATEGORY_RESERVED7
  public static let reserved08 = SDL_LOG_CATEGORY_RESERVED8
  public static let reserved09 = SDL_LOG_CATEGORY_RESERVED9
  public static let reserved10 = SDL_LOG_CATEGORY_RESERVED10
  
  public static let custom     = SDL_LOG_CATEGORY_CUSTOM
  
  public static var allCases: [SDL_LogCategory] {
    [
      .app
      , .error
      , .assert
      , .system
      , .audio
      , .video
      , .render
      , .input
      , .test
      , .gpu
      
      , .reserved02
      , .reserved03
      , .reserved04
      , .reserved05
      , .reserved06
      , .reserved07
      , .reserved08
      , .reserved09
      , .reserved10
      
      , .custom
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .app     : return "app"
      case .error   : return "error"
      case .assert  : return "assert"
      case .system  : return "system"
      case .audio   : return "audio"
      case .video   : return "video"
      case .render  : return "render"
      case .input   : return "input"
      case .test    : return "test"
      case .gpu     : return "gpu"
        
      case .reserved02: return "reserved02"
      case .reserved03: return "reserved03"
      case .reserved04: return "reserved04"
      case .reserved05: return "reserved05"
      case .reserved06: return "reserved06"
      case .reserved07: return "reserved07"
      case .reserved08: return "reserved08"
      case .reserved09: return "reserved09"
      case .reserved10: return "reserved10"
        
      case .custom: return "custom"
        
      default: return "Unknown SDL_LogCategory: \(self)"
    }
  }
}
