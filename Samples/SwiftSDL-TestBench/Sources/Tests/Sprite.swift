extension SDL.Test {
  final class Sprite: Game {
    static let configuration = CommandConfiguration(
      abstract: "Simple program:  Move N sprites around on the screen as fast as possible"
    )
    
    static let name: String = "SDL Test: Sprite"
    
    @OptionGroup var options: Options

    @Option(transform: {
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
    }) var blendMode: Flags.BlendMode = .blend
    
    /**
     `blend`
     `iterations`
     `cyclecolor`
     `cyclealpha`
     `suspend-when-occluded`
     `use-rendergeometry`
     `num_sprites`
     
     */
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
    }
  }
}

extension SDL.Test.Sprite {
  enum RenderMode {
    case mode0
    case mode1
    case mode2
  }
}
