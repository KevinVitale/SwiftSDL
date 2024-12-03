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
        .borderless(true),
        .width(250), .height(500)
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
    private var bgColor = SDL_Color(r: 0xA0, g: 0xA0, b: 0xA0, a: 0xFF)
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      self.renderer = try window.createRenderer()
      try self.renderer.set(vsync: options.vsync ? 1 : 0)
      
      self.sprite = try renderer
        .texture(from: Load(bitmap: image))
        .set(blendMode: blendMode)
      
      try window.sync(options: options)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      try renderer.clear(color: bgColor)
      try sprite.draw()
      try renderer.present()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      self.sprite = nil
      self.renderer = nil
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
