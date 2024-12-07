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
  
  nonisolated(unsafe) static weak var game: (any Game)!
  nonisolated(unsafe) static var window: (any Window)!
  nonisolated(unsafe) static var ticks: Uint64 = .max
  nonisolated(unsafe) static var failure: Failure = .noFailure
}

public struct SDL_AppMetadataFlags: RawRepresentable, Equatable, Sendable {
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public let rawValue: String
  
  public static let name = Self(rawValue: SDL_PROP_APP_METADATA_NAME_STRING)
  public static let version = Self(rawValue: SDL_PROP_APP_METADATA_VERSION_STRING)
  public static let identifier = Self(rawValue: SDL_PROP_APP_METADATA_IDENTIFIER_STRING)
  public static let creator = Self(rawValue: SDL_PROP_APP_METADATA_CREATOR_STRING)
  public static let copyright = Self(rawValue: SDL_PROP_APP_METADATA_COPYRIGHT_STRING)
  public static let url = Self(rawValue: SDL_PROP_APP_METADATA_URL_STRING)
  public static let type = Self(rawValue: SDL_PROP_APP_METADATA_TYPE_STRING)
}

extension SDL_AppResult: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let `continue` = SDL_APP_CONTINUE
  public static let success = SDL_APP_SUCCESS
  public static let failure = SDL_APP_FAILURE
  
  public static var allCases: [Self] {
    [
      .continue,
      .success,
      .failure
    ]
  }
  
  public var debugDescription: String {
    switch self {
      case .continue: return "continue"
      case .failure: return "failure"
      case .success: return "success"
      default: return "Unknown SDL_AppResult: \(self)"
    }
  }
}

struct AnyWindow {
  init(_ base: some Window) { self.base = base }
  let base: Any
}

struct AnyGame {
  init(_ base: some Game) { self.base = base }
  let base: Any
}

extension App {
  final class State {
    init(game: AnyGame, window: AnyWindow) {
      self._game = game
      self._window = window
    }
    
    private let _game: AnyGame
    private let _window: AnyWindow
    
    var game: any Game { _game.base as! (any Game) }
    var window: any Window { _window.base as! (any Window) }
  }
}
