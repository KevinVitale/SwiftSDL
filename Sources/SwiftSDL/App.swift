@available(*, deprecated)
enum App {
  enum Failure: CustomStringConvertible, CustomDebugStringConvertible {
    case noFailure
    case onInit(SDL_Error?)
    case onIterate(SDL_Error?)
    case onEvent(SDL_Error?)
    
    var error: SDL_Error? {
      switch self {
        case .noFailure: return nil
        case .onInit(let error): return error
        case .onIterate(let error): return error
        case .onEvent(let error): return error
      }
    }
    
    var debugDescription: String {
      switch self {
        case .noFailure: return ""
        case .onInit: return "onInit"
        case .onIterate: return "onIterate"
        case .onEvent: return "onEvent"
      }
    }
    
    var description: String {
      guard let error = error else {
        return debugDescription
      }
      return "\(debugDescription): \(error)"
    }
  }
  
  nonisolated(unsafe) static var frameInterval: (tick: Double, delta: Double) = (.nan, .nan)
  nonisolated(unsafe) static var failure: Failure = .noFailure
}

extension App {
  // https://gist.github.com/xeekworx/4ed45c039ea1676ddef1c2d9f921973d
  static func iterate(at now: Double = Double(SDL_GetPerformanceCounter()) / Double(SDL_GetPerformanceFrequency())) {
    var (tick, _) = frameInterval
    
    if tick.isNaN {
      tick = now
    }
    
    App.frameInterval = (now, now - tick)
  }
}

@propertyWrapper
struct FrameInterval {
  init(wrappedValue: Double = Double(SDL_GetPerformanceCounter())) {
    self.wrappedValue = wrappedValue
  }
  
  
  private var delta: Double = .nan
  private var tick: Double = .nan
  
  var wrappedValue: Double {
    get { tick }
    set {
      if tick.isNaN { self.tick = newValue }
      let prevTick = self.tick
      
      self.tick = newValue / Double(SDL_GetPerformanceFrequency())
      delta = self.tick - prevTick
    }
  }
}
