extension SDL.Games {
  final class FlappyBird: Game {
    enum CodingKeys: CodingKey {
      case options
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Keep flapping that bird!"
    )
    
    static let name: String = "SwiftSDL Game: Flappy Bird"
    
    @OptionGroup
    var options: SwiftSDL.GameOptions
    
    private var renderContext : RenderContext<FlappyBird> = .invalid
    private var gameState     : GameState = .uninitialized
    private var gameTextures  : [ImageAsset : any Texture] = [:]
    private var gameController: GameController = .invalid
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      
      let windowSize = try window.size(as: Float.self)
      let renderer = try window
        .createRenderer()
        .set(
          logicalSize: windowSize,
          presentation: .overscan
        )
      
      self.renderContext = .valid(renderer, self, .zero)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      self.renderContext.delta = delta
      try self.gameState.update(with: renderContext)
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      var event = event
      try self.renderContext.renderer?(SDL_ConvertEventToRenderCoordinates, .some(&event))
      
      switch event.eventType {
        case .gamepadButtonDown:
          if gameController.gamepad(isPressed: .south) ||
             gameController.gamepad(isPressed: .east)
          {
            try self.gameState.flap()
          }
          
          if gameController.gamepad(isPressed: .start) {
            self.gameState.pause()
          }

        case .keyDown where event.key.repeat == false: ()
          switch event.key.key {
            case SDLK_ESCAPE: self.gameState.pause()
            case SDLK_RETURN    : fallthrough
            case SDLK_A...SDLK_Z: fallthrough
            case SDLK_SPACE     : try self.gameState.flap()
            default: break
          }
        default: break
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      self.renderContext = .invalid
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
      self.gameState.pause()
      try gameController.open()
      self.gameController = gameController
    }
    
    func will(remove gameController: GameController) {
      self.gameController = self.gameControllers.last ?? .invalid
    }
    
    fileprivate subscript(_ image: ImageAsset) -> (any Texture)? {
      get { gameTextures[image] }
      set { gameTextures[image] = newValue }
    }
  }
}

extension SDL.Games.FlappyBird {
  fileprivate enum GameState: CustomDebugStringConvertible {
    case uninitialized
    case loading
    case ready(SDL.Games.FlappyBird)
    case flapping(Player, [Pipe])
    case deathFall(Player, [Pipe], Float)
    case gameOver(SDL.Games.FlappyBird)
    indirect case pause(GameState)
    
    var debugDescription: String {
      switch self {
        case .uninitialized: return "uninitialized"
        case .loading: return "loading"
        case .ready: return "ready"
        case .flapping: return "playing"
        case .deathFall: return "death fall"
        case .gameOver: return "game over"
        case .pause: return "paused"
      }
    }
    
    private var bgColor: SDL_Color {
      switch self {
        case .uninitialized: return .gray.setAlpha(to: 0)
        case .loading: return .yellow.setAlpha(to: 0)
        case .ready: return .white.setAlpha(to: 0)
        case .flapping: return .green.setAlpha(to: 0)
        case .deathFall: return .green.setAlpha(to: 0)
        case .gameOver: return .red.setAlpha(to: 0)
        case .pause(let gameState): return gameState.bgColor
      }
    }
    
    fileprivate mutating func start() throws(SDL_Error) {
      switch self {
        case .ready(let game) where game.renderContext.renderer != nil:
          let flappyBird = try createFlappyBird(game)
          let pipes = try createPipes(game)
          self = .flapping(flappyBird, pipes)
        case .gameOver(let game): self = .ready(game)
        default: break
      }
    }
    
    private func createFlappyBird(_ game: SDL.Games.FlappyBird) throws(SDL_Error) -> Player {
      let logicalSize     = try game.renderContext.logicalSize?.get().to(Float.self) ?? .zero
      let textureSize     = try game[.flappyBird]?.size(as: Float.self) ?? .zero
      let initialPosition = (logicalSize / 2).to(Float.self) - textureSize
      let flappyBird      = Player(position: initialPosition, size: textureSize)
      return flappyBird
    }
    
    private func createPipes(_ game: SDL.Games.FlappyBird) throws(SDL_Error) -> [Pipe] {
      let logicalSize = try game.renderContext.logicalSize?.get().to(Float.self) ?? .zero
      let pipeSpacing = 3 * (try game[.smallPipe]?.size(as: Float.self) ?? .zero).x
      return (0...5).map { idx in
        let startX = (logicalSize / 2).x * 1.333
        let xPos = startX + Float(idx) * pipeSpacing
        return .randomPair(at: [xPos, 0])
      }
    }
    
    fileprivate mutating func pause() {
      guard case(.pause(let gameState)) = self else {
        /* unless we're flapping, this function is a no-op */
        guard case(.flapping) = self else {
          return /* no-op */
        }
        
        /* pauses the flapping...*/
        return self = .pause(self)
      }
      
      /* revert to the state prior to being paused */
      self = gameState
    }
    
    fileprivate mutating func flap() throws(SDL_Error) {
      /* we have to be already flapping to keep...flapping... */
      guard case(.flapping(var player, let pipes)) = self else {
        return try start()
      }
      
      /* flap, flap, flap... */
      player.flap()
      self = .flapping(player, pipes)
    }
    
    fileprivate func update(with renderContext: SDL.Games.RenderContext<SDL.Games.FlappyBird>) throws(SDL_Error) -> Void {
      guard case(.valid(let renderer, let game, let delta)) = renderContext  else {
        return
      }
      
      try updateFunc(renderer, game, delta)
      try renderer
        .clear(color: bgColor)
        .pass(to: renderFunc, game)
        .present()
    }
    
    private var updateFunc: (any Renderer, SDL.Games.FlappyBird, UInt64) throws(SDL_Error) -> Void {
      switch self {
        case .uninitialized: return { renderer, game, _ in
          game.gameState = .loading
        }
          
        case .loading: return { renderer, game, _ in
          /* Load each image asset into the renderer (as a texture) */
          for imageAsset in ImageAsset.allCases {
            let surface = try Load(bitmap: imageAsset.fileName)
            let texture = try renderer.texture(
              from: surface,
              transparent: imageAsset.loadAsTransparent
            )
            game[imageAsset] = texture
          }
          
          /* The game is ready to begin... */
          game.gameState = .ready(game)
        }
          
        case .flapping(var player, var pipes): return { renderer, game, delta in
          let screenSize = try renderer.logicalSize.get().to(Float.self)
          let pipeSize = try game[.smallPipe]?.size(as: Float.self) ?? .zero
          
          // Let gravity take the wheel...
          let deltaInSecs = Float(delta) / 10000000
          player.fall(deltaInSecs)
          pipes = pipes.shifted(deltaInSecs, screenSize: screenSize, pipeSize: pipeSize, player: &player)
          
          /* Check for Y-Axis Collisions */
          if player.heightCheck(screenSize) {
            game.gameState = .gameOver(game)
          }
          
          /* Check for Pipe Collisions */
          else if try player.collisionCheck(pipes, screenSize: screenSize, game: game) {
            player.flap()
            game.gameState = .deathFall(player, pipes, FlapSettings.default.freezeDuration)
          }
          
          /* Just Keep Flappin' */
          else {
            // We MUST update the player value of the state we're in...
            game.gameState = .flapping(player, pipes)
          }
        }
          
        case .deathFall(var player, let pipes, var freezeDuration): return { renderer, game, delta in
          let deltaInSecs = Float(delta) / 10000000
          
          guard freezeDuration <= 0 else {
            freezeDuration -= deltaInSecs
            game.gameState = .deathFall(player, pipes, freezeDuration)
            return
          }
          let screenSize = try renderer.logicalSize.get().to(Float.self)
          
          /* Let gravity take the wheel... */
          player.fall(deltaInSecs)
          
          /* We fall until we can't */
          if player.position.y >= screenSize.y {
            game.gameState = .gameOver(game)
          }
          
          /* Just Keep Death Fallin' */
          else {
            // We MUST update the player value of the state we're in...
            game.gameState = .deathFall(player, pipes, freezeDuration)
          }
        }
          
        default: return { renderer, game, _ in
          /* no-op */
        }
      }
    }
    
    /// The rendering callback used for drawing the `GameState`.
    private var renderFunc: (_ renderer: any Renderer, _ game: SDL.Games.FlappyBird) throws(SDL_Error) -> Void {
      switch self {
        case .ready: return { renderer, game in
          let center = try renderer.logicalSize.get().to(Float.self) / 2
          let text = game.gameController != .invalid ? "A or B button to begin" : "Press ANY key to begin"
          let textScale: Size<Float> = [1.5, 1.5]
          let textSize = text.debugTextSize(as: Float.self)
          try renderer.debug(
            text: text,
            position: center / textScale - [textSize.x / 2, textSize.y * 5],
            color: .black,
            scale: [1.5, 1.5]
          )
        }
        case .flapping(let player, let pipes): return { renderer, game in
          let center = try renderer.logicalSize.get().to(Float.self) / 2
          let text = "SCORE: \(player.pipeCleared)"
          let textScale: Size<Float> = [1.5, 1.5]
          let textSize = text.debugTextSize(as: Float.self)
          try renderer
            .pass(to: Pipe.draw(_:_:_:), game, pipes)
            .draw(texture: game[.flappyBird], at: SDL_FPoint(player.position))
            .debug(
              text: text,
              position: center / textScale - [textSize.x / 2, textSize.y + center.y / 2] + [0, -32],
              color: .black,
              scale: [1.5, 1.5]
            )
        }
          
        case .deathFall(let player, let pipes, _): return { renderer, game in
          let center = try renderer.logicalSize.get().to(Float.self) / 2
          let text = "SCORE: \(player.pipeCleared)"
          let textScale: Size<Float> = [1.5, 1.5]
          let textSize = text.debugTextSize(as: Float.self)
          try renderer
            .pass(to: Pipe.draw(_:_:_:), game, pipes)
            .draw(texture: game[.flappyBird], at: SDL_FPoint(player.position))
            .debug(
              text: text,
              position: center / textScale - [textSize.x / 2, textSize.y + center.y / 2] + [0, -32],
              color: .black,
              scale: [1.5, 1.5]
            )
        }

        case .pause(let gameState): return gameState.renderFunc
          
        case .gameOver: return { renderer, game in
          let center = try renderer.logicalSize.get().to(Float.self) / 2
          let text = "GAME OVER"
          let textScale: Size<Float> = [1.5, 1.5]
          let textSize = text.debugTextSize(as: Float.self)
          try renderer.debug(
            text: text,
            position: center / textScale - [textSize.x / 2, textSize.y * 5],
            color: .black,
            scale: [1.5, 1.5]
          )
        }
        default:
          return { _, _ in
            
          }
      }
    }
  }
}

extension SDL.Games.FlappyBird {
  fileprivate struct Player: Identifiable {
    fileprivate let id = UUID()
    
    private let flapSettings: FlapSettings = .default
    fileprivate private(set) var velocity: Point<Float> = .zero
    
    fileprivate var score: Int = .zero
    fileprivate var position: Point<Float> = .zero
    fileprivate var size: Size<Float> = .zero
    fileprivate var pipeCleared: Int = .zero
    
    fileprivate mutating func fall(_ deltaInSeconds: Float) {
      self.velocity += [0, flapSettings.gravity * deltaInSeconds]
      self.position += velocity * deltaInSeconds
    }
    
    fileprivate mutating func heightCheck(_ size: Size<Float>) -> Bool {
      if position.y <= 0 {
        velocity = .zero
        position.y = 0
      }
      
      guard position.y < size.y else {
        return true
      }
      
      return false
    }
    
    fileprivate mutating func collisionCheck(_ pipes: [Pipe], screenSize: Size<Float>, game: SDL.Games.FlappyBird) throws(SDL_Error) -> Bool {
      let playerBoundsOriginal: Rect<Float> = [
        self.position.x, self.position.y,
        self.size.x, self.size.y
      ]
      
      let playerBounds = playerBoundsOriginal * [1.005, 1.005, 0.75, 0.75]
      try game.renderContext.renderer?.fill(rects: SDL_FRect(playerBounds), color: .blue)
      
      do {
        return try pipes.reduce(false) { result, pipe in
          let topImageAsset = game[pipe.top.imageAsset]
          let topPosition   = pipe.position
          var topPipeBounds = SDL_FRect(try pipe.top.bounds(at: topPosition, textureSize: topImageAsset?.size(as: Float.self) ?? .zero))

          let bottomImageAsset  = game[pipe.bottom.imageAsset]
          let bottomImageSize   = try bottomImageAsset?.size(as: Float.self) ?? .zero
          let bottomPosition    = Point([topPosition.x, screenSize.y - bottomImageSize.y])
          var bottomPipeBounds  = SDL_FRect(try pipe.bottom.bounds(at: bottomPosition, textureSize: bottomImageAsset?.size(as: Float.self) ?? .zero))
          
          let topPipeIntersect = SDL_FRect(playerBounds)(SDL_HasRectIntersectionFloat, .some(&topPipeBounds))
          let bottomPipeIntersect = SDL_FRect(playerBounds)(SDL_HasRectIntersectionFloat, .some(&bottomPipeBounds))
          
          return result || topPipeIntersect || bottomPipeIntersect
        }
      }
      catch {
        throw error as! SDL_Error
      }
    }
    
    /// Sets the velocity to `strength`
    fileprivate mutating func flap(strength: Float = FlapSettings.default.strength) {
      self.velocity = [0, strength]
    }
  }
  
  fileprivate enum Pipe {
    fileprivate enum Style: UInt8 {
      case small  = 1, smallInv = 4
      case mid    = 2, midInv   = 5
      case large  = 3, largeInv = 6
      
      var imageAsset: ImageAsset {
        switch self {
          case .small:    return .smallPipe
          case .smallInv: return .smallPipeInv
          case .mid:      return .midPipe
          case .midInv:   return .midPipeInv
          case .large:    return .largePipe
          case .largeInv: return .largePipeInv
        }
      }
      
      func bounds(at position: Point<Float>, textureSize: Size<Float>) throws(SDL_Error) -> Rect<Float> {
        return [
          position.x, position.y,
          textureSize.x, textureSize.y
        ]
      }
    }

    case pair(Style, Style, Point<Float>, Bool)
    
    var top: Style {
      switch self {
        case .pair(let style, _, _, _): return style
      }
    }
    
    var bottom: Style {
      switch self {
        case .pair(_, let style, _, _): return style
      }
    }

    var position: Point<Float> {
      switch self {
        case .pair(_, _, let position, _): return position
      }
    }
    
    var cleared: Bool {
      switch self {
        case .pair(_, _, _, let cleared): return cleared
      }
    }

    
    fileprivate mutating func shift(rate: Float = -2, _ deltaInSeconds: Float) {
      let velocity: Point<Float> = [rate, 0]
      let position = position + velocity * deltaInSeconds
      self = .pair(top, bottom, position, cleared)
    }
    
    fileprivate mutating func clear() {
      self = .pair(top, bottom, position, true)
    }


    static func randomPair(at point: Point<Float>) -> Self {
      let top    = Style(rawValue: .random(in: 1...3))!
      let bottom = Style(rawValue: .random(in: 4...6))!
      return .pair(top, bottom, point, false)
    }
    
    static func draw(_ renderer: any Renderer, _ game: SDL.Games.FlappyBird, _ pipes: [Self]) throws(SDL_Error) {
      let screenSize = try renderer.logicalSize.get().to(Float.self)
      for pipe in pipes {
        let topImageAsset = game[pipe.top.imageAsset]
        let topPosition = pipe.position
        
        let bottomImageAsset = game[pipe.bottom.imageAsset]
        let bottomImageSize = try bottomImageAsset?.size(as: Float.self) ?? .zero
        let bottomPosition = [topPosition.x, screenSize.y - bottomImageSize.y]
        
        try renderer
          .draw(texture: topImageAsset, at: SDL_FPoint(topPosition))
          .draw(texture: bottomImageAsset, at: SDL_FPoint(bottomPosition))
      }
    }
  }
}

extension Collection where Element == SDL.Games.FlappyBird.Pipe {
  fileprivate func shifted(_ deltaInSeconds: Float, screenSize: Size<Float>, pipeSize: Size<Float>, player: inout SDL.Games.FlappyBird.Player) -> [Element] {
    var pipes = Array(self)
    for (idx, var pipe) in pipes.enumerated() {
      pipe.shift(deltaInSeconds)
      if pipe.position.x <= player.position.x, !pipe.cleared {
        pipe.clear()
        player.pipeCleared += 1
      }
      pipes[idx] = pipe
    }
    
    pipes = pipes.filter { pipe in
      pipe.position.x + pipeSize.x > 0
    }
    
    if pipes.count <= 5 {
      // TODO: Consolidate this logic (copy-pasted from 'GameState.createPipes')
      let pipeSpacing = 3 * pipeSize.x
      let newPipes = (pipes.endIndex...5).map { idx in
        let startX = pipes[idx-1].position.x
        let xPos = startX + pipeSpacing
        return Element.randomPair(at: [xPos, 0])
      }
      pipes += newPipes
    }
    
    return pipes
  }
}

extension SDL.Games.FlappyBird {
  fileprivate struct FlapSettings {
    private init() { }
    
    let gravity: Float = 0.25
    let strength: Float = -4
    let freezeDuration: Float = 50
    
    fileprivate static let `default` = FlapSettings()
  }
}

extension SDL.Games.FlappyBird {
  fileprivate enum ImageAsset: String, CaseIterable {
    case flappyBird   = "Flappy Bird"
    case background   = "Background"
    case smallPipe    = "Small Pipe"
    case smallPipeInv = "Small Pipe Inverted"
    case midPipe      = "Mid Pipe"
    case midPipeInv   = "Mid Pipe Inverted"
    case largePipe    = "Long Pipe"
    case largePipeInv = "Long Pipe Inverted"

    var loadAsTransparent: Bool { true }
    
    var fileName: String {
      switch self {
        case .background: return "flappy_background.bmp"
        case .flappyBird: return "flappy_bird.bmp"
        case .smallPipe: return "flappy_pipe_small.bmp"
        case .smallPipeInv: return "flappy_pipe_inverted_small.bmp"
        case .midPipe: return "flappy_pipe_mid.bmp"
        case .midPipeInv: return "flappy_pipe_inverted_mid.bmp"
        case .largePipe: return "flappy_pipe_large.bmp"
        case .largePipeInv: return "flappy_pipe_inverted_large.bmp"
      }
    }
    
    static var allCases: [Self] {
      [
        .background
        , .flappyBird
        , .smallPipe
        , .smallPipeInv
        , .midPipe
        , .midPipeInv
        , .largePipe
        , .largePipeInv
      ]
    }
  }
}
