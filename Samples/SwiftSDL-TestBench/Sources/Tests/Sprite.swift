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
    ) var iterations: Iterations = .forever
    
    @Argument(
      help: "Number of sprites"
    ) var count: Int = 100

    @Argument(
      help: "Image to use for the sprites"
    ) var image: String = "icon.bmp"
    
    private var renderer: (any Renderer)! = nil
    private var rendererMode: RenderMode = .default
    private var sprite: (any Texture)! = nil
    private var positions: [SDL_FPoint] = []
    private var velocities: [SDL_FPoint] = []
    private var bgColor = SDL_Color(r: 0xA0, g: 0xA0, b: 0xA0, a: 0x00)
    private var frameCounter = FrameCounter()
    private var colorCycle: CycleValue = .color(0, 1)
    private var alphaCycle: CycleValue = .alpha(0, 1)

    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      guard renderMode == .default else {
        fatalError("\"\(renderMode)\" is not yet implemented. Don't use --render-mode")
      }
      self.renderer = try window.createRenderer()
      
      self.sprite = try renderer
        .texture(from: Load(bitmap: image), transparent: true)
        .set(blendMode: blendMode)
      
      print("Blend mode: \(try self.sprite.blendMode.get())")
      
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
      
      frameCounter.start(delayAmount: 5000)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      colorCycle.step(); alphaCycle.step()
      try sprite.set(colorMod: .max, colorCycle.component, colorCycle.component)
      try sprite.set(alphaMod: alphaCycle.component)

      try renderer
        .set(viewport: nil)
        .set(viewport: renderer.safeArea)
        .clear(color: bgColor)
        .pass(to: _drawTestPoints(_:viewport:), renderer.viewport)
        .pass(to: _drawTestLines(_:viewport:), renderer.viewport)
        .pass(to: _drawTestRects(_:viewport:), renderer.viewport)
        .pass(to: _drawSprites(_:viewport:), renderer.viewport)
        .present()
      
      frameCounter.increment()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      self.sprite = nil
      self.renderer = nil
    }
    
    private func _drawTestPoints(_ renderer: any Renderer, viewport: Result<Rect<Int32>, SDL_Error>) throws(SDL_Error) {
      let viewport    = SDL_FRect(try viewport.get().to(Float.self))
      let topLeft     = SDL_FPoint([viewport[0], viewport[1]])
      let topRight    = SDL_FPoint([viewport[2], viewport[0]])
      let bottomLeft  = SDL_FPoint([viewport[0], viewport[3]])
      let bottomRight = SDL_FPoint([viewport[2], viewport[3]])
      try renderer.points(topLeft, topRight, bottomLeft, bottomRight, color: 0xFF, 0x00, 0x00, 0xFF)
    }

    private func _drawTestLines(_ renderer: any Renderer, viewport: Result<Rect<Int32>, SDL_Error>) throws(SDL_Error) {
      let viewport    = SDL_FRect(try viewport.get().to(Float.self))
      let spriteSize  = SDL_FSize(try sprite.size(as: Float.self))
      let topLeft     = SDL_FPoint([viewport[0], viewport[1]])
      let topRight    = SDL_FPoint([viewport[2], viewport[0]])
      let bottomLeft  = SDL_FPoint([viewport[0], viewport[3]])
      let bottomRight = SDL_FPoint([viewport[2], viewport[3]])
      // Top-Bottom (Green)
      try renderer.lines(topLeft, topRight, color: 0x00, 0xFF, 0x00, 0xFF)
      try renderer.lines(bottomLeft - [0, 1], bottomRight - [0, 1], color: 0x00, 0xFF, 0x00, 0xFF)
      
      // Left-Right (Blue)
      try renderer.lines(topLeft, bottomLeft, color: 0x00, 0x00, 0xFF, 0xFF)
      try renderer.lines(topRight - [1, 0], bottomRight - [1, 0], color: 0x00, 0x00, 0xFF, 0xFF)
      
      // Diagonal 1 (Green)
      try renderer.lines(topLeft + spriteSize, bottomRight - spriteSize, color: 0x00, 0xFF, 0x00, 0xFF)

      // Diagonal 2 (Green)
      try renderer.lines(topRight - [spriteSize.x, -spriteSize.y], bottomLeft - [-spriteSize.x, spriteSize.y], color: 0x00, 0xFF, 0x00, 0xFF)
    }
    
    private func _drawTestRects(_ renderer: any Renderer, viewport: Result<Rect<Int32>, SDL_Error>) throws(SDL_Error) {
      let viewport    = SDL_FRect(try viewport.get().to(Float.self))
      let spriteSize  = SDL_FSize(try sprite.size(as: Float.self))
      let topLeft     = SDL_FPoint([viewport[0], viewport[1]])
      let topRight    = SDL_FPoint([viewport[2], viewport[0]])
      let bottomLeft  = SDL_FPoint([viewport[0], viewport[3]])
      let bottomRight = SDL_FPoint([viewport[2], viewport[3]])
      try renderer.fill(rects: [
        [topLeft.x, topLeft.y, spriteSize.x, spriteSize.y],
        [topRight.x - spriteSize.x, topRight.y, spriteSize.x, spriteSize.y],
        [bottomLeft.x, bottomLeft.y - spriteSize.y, spriteSize.x, spriteSize.y],
        [bottomRight.x - spriteSize.x, bottomRight.y - spriteSize.y, spriteSize.x, spriteSize.y],
      ], color: .white)
    }

    private func _drawSprites(_ renderer: any Renderer, viewport: Result<Rect<Int32>, SDL_Error>) throws(SDL_Error) {
      let viewport = try viewport.get().to(Float.self)
      let spriteSize = SDL_FSize(try sprite.size(as: Float.self))
      
      for (idx, (var position, var velocity)) in zip(positions, velocities).enumerated() {
        _moveSprite(
          sized: spriteSize,
          to: &position,
          at: &velocity,
          in: viewport
        )
        
        positions[idx] = position
        velocities[idx] = velocity
        
        try renderer.draw(texture: sprite, at: position)
      }
      
      // Decrement the iteration value. Only applies when the test
      // was started with an explicit iteration value. Otherwise,
      // sprites are moved forever.
      iterations.decrement()
    }
    
    private func _moveSprite(sized size: SDL_FSize, to position: inout  SDL_FPoint, at velocity: inout SDL_FPoint, in viewport: Rect<Float>) {
      // Only move sprite either when 'forever' or 'count' are set...
      guard iterations != .none else {
        return
      }
      
      position.x += velocity.x
      if ((position.x < 0) || (position.x >= (viewport[2] - size.x))) {
        velocity.x = -velocity.x;
        position.x += velocity.x;
      }
      
      position.y += velocity.y
      if ((position.y < 0) || (position.y >= (viewport[3] - size.y))) {
        velocity.y = -velocity.y;
        position.y += velocity.y;
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
  enum CycleValue {
    case color(Int16, Int16)
    case alpha(Int16, Int16)
    
    var component: UInt8 {
      UInt8(rawValue)
    }
    
    private var rawValue: Int16 {
      switch self {
        case .color(let value, _): return value
        case .alpha(let value, _): return value
      }
    }
    
    private var direction: Int16 {
      switch self {
        case .color(_, let direction): return direction
        case .alpha(_, let direction): return direction
      }
    }
    
    mutating func step() {
      var direction = direction
      var rawValue = rawValue + direction
      
      if rawValue <= UInt8.min {
        rawValue = 0
        direction.negate()
      }
      if rawValue > UInt8.max {
        rawValue = Int16(UInt8.max)
        direction.negate()
      }
      
      switch self {
        case .color: self = .color(rawValue, direction)
        case .alpha: self = .alpha(rawValue, direction)
      }
    }
  }
}

extension SDL.Test.Sprite {
  struct FrameCounter {
    private var frameDelayAmount: UInt64 = 0
    private var nextFPSCheck: UInt64 = 0
    private var frames: Int32 = 0
    
    mutating func start(delayAmount: UInt64 = 5000) {
      frameDelayAmount = delayAmount
      nextFPSCheck = SDL_GetTicks() + delayAmount
    }
    
    mutating func increment() {
      frames += 1
      let now = SDL_GetTicks()
      if now >= nextFPSCheck {
        let then = nextFPSCheck - frameDelayAmount
        let fps  = Double(frames * 1000) / Double(now - then)
        print(String(format: "%2.2f frames per second", fps))
        nextFPSCheck = now + frameDelayAmount
        frames = 0
      }
    }
  }
}

extension SDL.Test.Sprite {
  enum Iterations: RawRepresentable, ExpressibleByArgument {
    init?(rawValue: Int) {
      switch rawValue {
        case ..<0: self = .forever
        case 0: self = .none
        default: self = .count(rawValue)
      }
    }
    
    typealias RawValue = Int
    
    case none
    case forever
    case count(Int)
    
    var rawValue: Int {
      switch self {
        case .forever: return -1
        case .count(let count): return count
        case .none: return 0
      }
    }
    
    var defaultValueDescription: String {
      switch self {
        case .none: return "none"
        case .forever: return "forever"
        case .count(let count): return "\(count)"
      }
    }
    
    mutating func decrement() {
      switch self {
        case .count(var count):
          count -= 1
          self = count > 0 ? .count(count) : .none
        default: break
      }
    }
  }
}
