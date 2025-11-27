/**
 A special error type, that indicates which phase of the game loop
 a runtime error may have occurred. Sent to `onShutdown(_:_:)`.
 */
public enum GameLoopFailure: Error, Sendable {
  case onInit(SDL_Error)
  case onIterate(SDL_Error)
  case onEvent(SDL_Error)
  case none
  
  public var error: SDL_Error? {
    switch self {
      case .onInit(let error): return error
      case .onIterate(let error): return error
      case .onEvent(let error): return error
      case .none: return nil
    }
  }
}

final class __GameLoopFailure: SDL_PropertyTypeValue, Sendable {
  enum CallbackState: String {
    case onInit
    case onIterate
    case onEvent
    case none
  }
  
  let error: SDL_Error
  let state: CallbackState
  
  init(error: SDL_Error, state: CallbackState) {
    self.error = error
    self.state = state
  }
  
  var gameLoopFailure: GameLoopFailure {
    switch state {
      case .onInit: return .onInit(error)
      case .onIterate: return .onIterate(error)
      case .onEvent: return .onEvent(error)
      default: return .none
    }
  }
}

