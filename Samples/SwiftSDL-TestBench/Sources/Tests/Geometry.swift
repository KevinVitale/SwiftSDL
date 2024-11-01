extension SDL.Test {
  final class Geometry: Game {
    enum CodingKeys: String, CodingKey {
      case options
      case blendMode
      case useTexture
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program: draw a RGB triangle, with texture"
    )
    
    static let name: String = "SDL Test: Geometry"
    
    @OptionGroup var options: Options
    
    @Option(transform: {
      switch $0 {
        case "blend": return .blend
        case "add": return .add
        case "mod": return .mod
        case "mul": return .mul
        default: return .none
      }
    }) var blendMode: Flags.BlendMode = .none
    
    @Flag(name: [
      .customLong("use-texture"),
      .customShort("t")
    ]) var useTexture: Bool = false
    
    private var icon: (any Texture)!
    private var trianglePos: Point<Int32> = .zero
    private var triangleAngle: Float = .zero

    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      if !options.title.isEmpty {
        try window.set(title: options.title)
      }
      
      let renderer = try window.createRenderer()
      try _loadTexture(renderer)

      if options.vsync {
        try renderer.set(vsync: SDL_RENDERER_VSYNC_ADAPTIVE)
      }
    }
    
    func onUpdate(window: any Window, _ delta: Tick) throws(SwiftSDL.SDL_Error) {
      let renderer = try window.renderer.get()
      
      // Clears th framebuffer (uses 'blendMode' option passed in at runtime).
      try renderer
        .set(blendMode: blendMode)
        .clear(color: .init(r: 0xA0, g: 0xA0, b: 0xA0, a: 0xFF))
      
      // Draws geometry (evaluates 'useTexture' option passed in at runtime).
      try self._drawGeometry(renderer)
      
      // Presents framebuffer content onto 'window'.
      try renderer.present()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      switch event.eventType {
        case .mouseMotion:
          // FIXME: avoid raw value comparisons
          if event.motion.state != .zero {
            let windowSize = try window.size(as: Float.self)
            let relPos = event.motion.relative(as: Float.self)
            if event.motion.y < windowSize.y / 2 {
              triangleAngle += relPos.x
            }
            else {
              triangleAngle -= relPos.x
            }
            
            if event.motion.x < windowSize.x / 2 {
              triangleAngle -= relPos.y
            }
            else {
              triangleAngle += relPos.y
            }
          }
        case .keyDown:
          switch event.key {
            case SDLK_LEFT: trianglePos &-= [1, 0]
            case SDLK_RIGHT: trianglePos &+= [1, 0]
            case SDLK_UP: trianglePos &-= [0, 1]
            case SDLK_DOWN: trianglePos &+= [0, 1]
            default: ()
          }
        default: return
      }
    }
    
    func onShutdown(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      icon?.destroy()
    }
    
    @MainActor private func _loadTexture(_ renderer: any Renderer) throws(SDL_Error) {
      let surface = try Self.load(bitmap: "icon.bmp")
      self.icon = try renderer.texture(from: surface)
      try self.icon(SDL_SetTextureBlendMode, blendMode.rawValue)
      surface.destroy()
    }
    
    @MainActor private func _drawGeometry(_ renderer: any Renderer) throws(SDL_Error) {
      var verts: [SDL_Vertex] = Array(repeating: .init(), count: 3)
      let viewport = try renderer.viewport.get().to(Float.self)
      
      var cPos = viewport.lowHalf
      cPos += viewport.highHalf / 2
      cPos += trianglePos.to(Float.self)
      let d = (viewport.highHalf.x + viewport.highHalf.y) / 5

      var angle = triangleAngle * SDL_PI_F / 180
      verts[0].position.x = cPos.x + d * SDL_cosf(angle)
      verts[0].position.y = cPos.y + d * SDL_sinf(angle)
      verts[0].color.r = 1.0
      verts[0].color.g = 0.0
      verts[0].color.b = 0.0
      verts[0].color.a = 1.0
      
      angle = (triangleAngle + 120) * SDL_PI_F / 180
      verts[1].position.x = cPos.x + d * SDL_cosf(angle)
      verts[1].position.y = cPos.y + d * SDL_sinf(angle)
      verts[1].color.r = 0.0
      verts[1].color.g = 1.0
      verts[1].color.b = 0.0
      verts[1].color.a = 1.0

      angle = (triangleAngle + 240) * SDL_PI_F / 180
      verts[2].position.x = cPos.x + d * SDL_cosf(angle)
      verts[2].position.y = cPos.y + d * SDL_sinf(angle)
      verts[2].color.r = 0.0
      verts[2].color.g = 0.0
      verts[2].color.b = 1.0
      verts[2].color.a = 1.0

      if useTexture {
        verts[0].tex_coord.x = 0.5;
        verts[0].tex_coord.y = 0.0;
        verts[1].tex_coord.x = 1.0;
        verts[1].tex_coord.y = 1.0;
        verts[2].tex_coord.x = 0.0;
        verts[2].tex_coord.y = 1.0;
      }
      
      try renderer(
        SDL_RenderGeometry,
        icon.pointer,
        verts.withUnsafeBufferPointer(\.baseAddress),
        3,
        nil,
        0
      )
    }
  }
}
