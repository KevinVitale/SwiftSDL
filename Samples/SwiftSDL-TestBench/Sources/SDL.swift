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
        MouseGrid.self,
        GPUExamples.self,
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
  enum RenderContext {
    /// A context with no associate `renderer` or `game`.
    case invalid
    
    /// A context with an associated `renderer` and `game`.
    case valid(any Renderer)
    
    /// The `renderer` of a `valid` context.
    ///
    /// If the context is `invalid`, this returns `nil`.
    var renderer: (any Renderer)? {
      get {
        switch self {
          case .invalid: return nil
          case .valid(let renderer): return renderer
        }
      }
      set {
        guard case(.valid) = self, let renderer = newValue else {
          return
        }
        self = .valid(renderer)
      }
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<any Renderer, Value>) -> Value? {
      renderer?[keyPath: keyPath]
    }
  }
}

func Load(bitmap: String) throws(SDL_Error) -> some Surface {
  try SDL_Load(
    bitmap: bitmap,
    searchingBundles: Bundle.resourceBundles(matching: {
      $0.lastPathComponent.contains("SwiftSDL-TestBench")
    })
  )
}

func Load(
  shader file: String,
  device gpuDevice: any GPUDevice,
  samplerCount: UInt32 = 0,
  uniformBufferCount: UInt32 = 0,
  storageBufferCount: UInt32 = 0,
  storageTextureCount: UInt32 = 0,
  propertyID: SDL_PropertiesID = 0
) throws(SDL_Error) -> some GPUShader {
  try SDL_Load(
    shader: file,
    device: gpuDevice,
    samplerCount: samplerCount,
    uniformBufferCount: uniformBufferCount,
    storageBufferCount: storageBufferCount,
    storageTextureCount: storageTextureCount,
    propertyID: propertyID,
    searchingBundles: Bundle.resourceBundles(matching: {
      $0.lastPathComponent.contains("SwiftSDL-TestBench")
    })
  )
}
