@_exported import SwiftSDL

@main struct SDL: ParsableCommand {
  static let configuration = CommandConfiguration(
    groupedSubcommands: [
      .init(name: "games", subcommands: [Games.self]),
      .init(name: "test", subcommands: [Test.self])
    ]
  )
}

extension SDL {
  struct Test: ParsableCommand {
    typealias Options = GameOptions
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL tests reimplemented using SwiftSDL.",
      subcommands: [
        AudioInfo.self,
        Camera.self,
        Controller.self,
        Geometry.self,
        SpinningCube.self,
        Sprite.self,
      ]
    )
  }
}

extension SDL {
  struct Games: ParsableCommand {
    typealias Options = GameOptions
    
    static let configuration = CommandConfiguration(
      abstract: "Run a variety SDL game examples implemented using SwiftSDL.",
      subcommands: [
        FlappyBird.self,
        Sandbox.self,
        StinkyDuck.self
      ]
    )
  }
}

extension SDL.Games {
  @dynamicMemberLookup
  enum RenderContext<Game: SwiftSDL.Game> {
    /// A context with no associate `renderer` or `game`.
    case invalid
    
    /// A context with an associated `renderer` and `game`.
    case valid(any Renderer, Game, Uint64)
    
    /**
     Sets a `valid` rendering context to the latest `delta` value.
     
     - parameter delta: The amount (in nanoseconds) since the previous frame was drawn.
     */
    mutating func tick(_ delta: Uint64) {
      switch self {
        case .invalid: return
        case .valid(let renderer, let game, _): self = .valid(renderer, game, delta)
      }
    }
    
    /// The `renderer` of a `valid` context.
    ///
    /// If the context is `invalid`, this returns `nil`.
    var renderer: (any Renderer)? {
      switch self {
        case .invalid: return nil
        case .valid(let renderer, _, _): return renderer
      }
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<any Renderer, Value>) -> Value? {
      renderer?[keyPath: keyPath]
    }
  }
}


func Load(bitmap: String) throws(SDL_Error) -> any Surface {
  try SDL_Load(
    bitmap: bitmap,
    searchingBundles: Bundle.resourceBundles(matching: {
      $0.lastPathComponent.contains("SwiftSDL-TestBench")
    })
  )
}
