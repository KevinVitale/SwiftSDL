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
    
    @Option(
      name: .customLong("blend"),
      help: "Blend mode used for drawing operations",
      transform: {
        switch $0 {
          case "blend": return .blend
          case "add": return .add
          case "mod": return .mod
          case "mul": return .mul
          default: return .none
        }
      }) var blendMode: SDL_BlendMode = .blend
    
    @Flag(name: [
      .customLong("use-texture"),
      .customShort("t")
    ], help: "Render geometry with a texture"
    ) var useTexture: Bool = false

    private var renderer: (any Renderer)! = nil
    private var icon: (any Texture)! = nil
    private var trianglePos: Point<Int32> = .zero
    private var triangleAngle: Float = .zero

    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      renderer = try window.createRenderer()
      let icon = try renderer.texture(from: try Load(bitmap: "icon.bmp"))
      try icon.set(blendMode: blendMode)
      
      self.icon = icon
    }
    
    func onUpdate(window: any Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      try renderer
        // Clears the framebuffer
        .clear(color: .init(r: 0xA0, g: 0xA0, b: 0xA0, a: 0xFF))
        // Use the 'blendMode' option passed in at runtime
        .set(blendMode: blendMode)
        // Draws geometry (evaluates 'useTexture' option passed in at runtime)
        .draw(into: self._drawGeometry(_:))
        // Presents framebuffer content onto 'window'
        .present()
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
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      icon = nil
      renderer = nil
    }
    
    private func _loadTexture(_ renderer: any Renderer) throws(SDL_Error) {
      let surface = try Load(bitmap: "icon.bmp")
      self.icon = try renderer.texture(from: surface)
      try self.icon(SDL_SetTextureBlendMode, blendMode.rawValue)
      // surface.destroy()
    }
    
    private func _drawGeometry(_ renderer: any Renderer) throws(SDL_Error) {
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
