extension SDL.Test {
  final class Sprite: Game {
    enum CodingKeys: String, CodingKey {
      case options
      case blendMode
      case cyclecolor
      case cyclealpha
      case suspendWhenOccluded
      case renderMode
      case iterations
      case image
      case count
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program:  Move N sprites around on the screen as fast as possible"
    )
    
    static let name: String = "SDL Test: Sprite"
    
    static var windowProperties: [WindowProperty] {
      [
        .windowTitle(Self.name),
        .width(640), .height(480)
      ]
    }
    
    @OptionGroup var options: Options

    @Option(
      name: .customLong("blend"),
      help: "Blend mode used for drawing operations",
      transform: {
        switch $0 {
          case "none": return .none
          case "blend": return .blend
          case "blend_premultiplied": return .blendPremul
          case "add": return .add
          case "add_premultiplied": return .addPremul
          case "mod": return .mod
          case "mul": return .mul
            /* testsprite.c:437... sub? */
          default: return .none
        }
      }) var blendMode: SDL_BlendMode = .blend
    
    @Flag(
      name: .customLong("cycle-color"),
      help: "Changes the images color every frame"
    )
    var cyclecolor: Bool = false
    
    @Flag(
      name: .customLong("cycle-alpha"),
      help: "Changes the transparency color every frame"
    )
    var cyclealpha: Bool = false
    
    @Flag(
      name: .shortAndLong,
      help: "Pause the program when the window is occluded"
    )
    var suspendWhenOccluded: Bool = false
    
    @Option(
      name: .shortAndLong,
      help: "Rendering mode to use",
      transform: {
        switch $0 {
          case "mode1": return .mode1
          case "mode2": return .mode2
          default: return .default
        }
      }
    ) var renderMode: RenderMode = .default

    @Option(
      help: "Number of iterations to run"
    ) var iterations: Iterations = .random
    
    @Argument(
      help: "Number of sprites"
    ) var count: Int = 100

    @Argument(
      help: "Image to use for the sprites"
    ) var image: String = "icon.bmp"
    
    private var renderer: (any Renderer)! = nil
    private var sprite: (any Texture)! = nil
    private var positions: [SDL_FPoint] = []
    private var velocities: [SDL_FPoint] = []
    private var bgColor = SDL_Color(r: 0xA0, g: 0xA0, b: 0xA0, a: 0x00)
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      self.renderer = try window.createRenderer()
      
      self.sprite = try renderer
        .texture(from: Load(bitmap: image))
        .set(blendMode: blendMode)
      
      let spriteSize = (try sprite.size(as: Int32.self))
      let safeArea = try renderer.safeArea.get()
      let drawSize = safeArea.highHalf &- spriteSize

      for _ in 0..<count {
        let randX = Float(Int32.random(in: 0..<drawSize.x))
        let randY = Float(Int32.random(in: 0..<drawSize.y))
        let position = SDL_FPoint([randX, randY])
        positions.append(position)
        
        let veloX = Float.random(in: -1...1)
        let veloY = Float.random(in: -1...1)
        let velocity = SDL_FPoint([veloX, veloY])
        velocities.append(velocity)
      }
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      try renderer
        .set(viewport: nil)
        .set(viewport: renderer.safeArea)
        .clear(color: bgColor)
        .pass(to: _drawTestPoints(_:viewport:), renderer.viewport)
        .pass(to: _drawTestLines(_:))
        .pass(to: _drawSprites(_:))
        .present()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      self.sprite = nil
      self.renderer = nil
    }
    
    private func _drawTestPoints(_ renderer: any Renderer, viewport: Result<Rect<Int32>, SDL_Error>) throws(SDL_Error) {
      let viewport    = SDL_FRect(try viewport.get().to(Float.self))
      let topLeft     = SDL_FPoint([0, 0])
      let topRight    = SDL_FPoint([viewport[2] - 1, 0])
      let bottomLeft  = SDL_FPoint([0, viewport[3] - 1])
      let bottomRight = SDL_FPoint([viewport[2] - 1, viewport[3] - 1])
      try renderer.points(topLeft, topRight, bottomLeft, bottomRight, color: 0xFF, 0x00, 0x00, 0xFF)
    }

    private func _drawTestLines(_ renderer: any Renderer) throws(SDL_Error) {
    }
    
    private func _drawSprites(_ renderer: any Renderer) throws(SDL_Error) {
      for position in positions {
        try renderer.draw(texture: sprite, at: position)
      }
    }
  }
}

extension SDL.Test.Sprite {
  enum RenderMode: String {
    case `default`
    case mode1
    case mode2
  }
}

extension SDL.Test.Sprite {
  enum Iterations: RawRepresentable, ExpressibleByArgument {
    init?(rawValue: Int) {
      guard rawValue >= 0 else {
        self = .random
        return
      }
      self = .count(rawValue)
    }
    
    typealias RawValue = Int
    
    case random
    case count(Int)
    
    var rawValue: Int {
      switch self {
        case .random: return -1
        case .count(let count): return count
      }
    }
    
    var seedValue: UInt64 {
      switch self {
        case .random: return SDL_GetPerformanceCounter()
        case .count(let count): return UInt64(count)
      }
    }
    
    var defaultValueDescription: String {
      switch self {
        case .random: return "random"
        case .count(let count): return "\(count)"
      }
    }
  }
}
