extension SDL.Games {
  final class StinkyDuck: Game {
    private enum CodingKeys: CodingKey {
      case options
    }
    
    @OptionGroup
    var options: GameOptions
    
    fileprivate var renderContext : RenderContext<StinkyDuck> = .invalid
    private var gameState         : GameState = .uninitialized
    private var gameController    : GameController = .invalid
    private var gameTextures      : [ImageAsset : any Texture] = [:]
    private var ducks             : [Fowl] = [
      .init(position: [128, 128], state: .idleNormal(.idleNormalUp, 0)),
      .init(position: [128, 192], state: .idleBounce(.idleBounceStep1, 0)),
      .init(position: [128, 256], state: .walkNormal(.walkNormalStep1, 0)),
      .init(position: [128, 320], state: .walkBounce(.walkBounceStep1, 0))
    ]

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
      switch event.eventType {
        case .keyDown:
          switch event.key.key {
            // case SDLK_RIGHT : self.player.state = .walkNormal(.walkNormalStep1)
            default: break
          }
        case .keyUp: ()
          //  self.player.state = .idleNormal(.idleBounceStep1)
        default: break
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
    }
    
    func did(connect gameController: inout GameController) throws(SDL_Error) {
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

extension SDL.Games.StinkyDuck {
  fileprivate struct Fowl {
    /// https://caz-creates-games.itch.io/ducky-3?download
    fileprivate enum Animation: Identifiable {
      case idleNormalUp
      case idleNormalDown
      
      case walkNormalStep1
      case walkNormalStep2
      case walkNormalStep3
      case walkNormalStep4
      case walkNormalStep5
      case walkNormalStep6

      case idleBounceStep1
      case idleBounceStep2
      case idleBounceStep3
      case idleBounceStep4
      
      case walkBounceStep1
      case walkBounceStep2
      case walkBounceStep3
      case walkBounceStep4
      case walkBounceStep5
      case walkBounceStep6

      var id: Int {
        switch self {
          case .idleNormalUp: fallthrough
          case .idleNormalDown: return 0
            
          case .walkNormalStep1: fallthrough
          case .walkNormalStep2: fallthrough
          case .walkNormalStep3: fallthrough
          case .walkNormalStep4: fallthrough
          case .walkNormalStep5: fallthrough
          case .walkNormalStep6: return 1

          case .idleBounceStep1: fallthrough
          case .idleBounceStep2: fallthrough
          case .idleBounceStep3: fallthrough
          case .idleBounceStep4: return 2
            
          case .walkBounceStep1: fallthrough
          case .walkBounceStep2: fallthrough
          case .walkBounceStep3: fallthrough
          case .walkBounceStep4: fallthrough
          case .walkBounceStep5: fallthrough
          case .walkBounceStep6: return 3
        }
      }
      
      var frame: Int {
        switch self {
          case .idleNormalUp: return 0
          case .idleNormalDown: return 1
            
          case .walkNormalStep1: return 0
          case .walkNormalStep2: return 1
          case .walkNormalStep3: return 2
          case .walkNormalStep4: return 3
          case .walkNormalStep5: return 4
          case .walkNormalStep6: return 5
            
          case .idleBounceStep1: return 0
          case .idleBounceStep2: return 1
          case .idleBounceStep3: return 2
          case .idleBounceStep4: return 3
            
          case .walkBounceStep1: return 0
          case .walkBounceStep2: return 1
          case .walkBounceStep3: return 2
          case .walkBounceStep4: return 3
          case .walkBounceStep5: return 4
          case .walkBounceStep6: return 5
        }
      }
      
      var duration: Float {
        switch self {
          case .idleNormalUp: fallthrough
          case .idleNormalDown: return 45
            
          case .walkNormalStep1: fallthrough
          case .walkNormalStep2: fallthrough
          case .walkNormalStep3: fallthrough
          case .walkNormalStep4: fallthrough
          case .walkNormalStep5: fallthrough
          case .walkNormalStep6: return 10

          case .idleBounceStep1: fallthrough
          case .idleBounceStep2: fallthrough
          case .idleBounceStep3: fallthrough
          case .idleBounceStep4: return 15
            
          case .walkBounceStep1: fallthrough
          case .walkBounceStep2: fallthrough
          case .walkBounceStep3: fallthrough
          case .walkBounceStep4: fallthrough
          case .walkBounceStep5: fallthrough
          case .walkBounceStep6: return 15
        }
      }
      
      mutating func swap() {
        switch self {
          case .idleNormalUp: self = .idleNormalDown
          case .idleNormalDown: self = .idleNormalUp
            
          case .walkNormalStep1: self = .walkNormalStep2
          case .walkNormalStep2: self = .walkNormalStep3
          case .walkNormalStep3: self = .walkNormalStep4
          case .walkNormalStep4: self = .walkNormalStep5
          case .walkNormalStep5: self = .walkNormalStep6
          case .walkNormalStep6: self = .walkNormalStep1

          case .idleBounceStep1: self = .idleBounceStep2
          case .idleBounceStep2: self = .idleBounceStep3
          case .idleBounceStep3: self = .idleBounceStep4
          case .idleBounceStep4: self = .idleBounceStep1
            
          case .walkBounceStep1: self = .walkBounceStep2
          case .walkBounceStep2: self = .walkBounceStep3
          case .walkBounceStep3: self = .walkBounceStep4
          case .walkBounceStep4: self = .walkBounceStep5
          case .walkBounceStep5: self = .walkBounceStep6
          case .walkBounceStep6: self = .walkBounceStep1
        }
      }
    }
    
    fileprivate enum State: CaseIterable {
      case idleNormal(Animation, Float)
      case walkNormal(Animation, Float)
      case idleBounce(Animation, Float)
      case walkBounce(Animation, Float)

      static var allCases: [Self] {
        [
          .idleNormal(.idleNormalUp, 0),
          .idleBounce(.idleBounceStep1, 0),
          .walkNormal(.walkNormalStep1, 0),
          .walkBounce(.walkBounceStep1, 0)
        ]
      }
      
      var time: Float {
        get {
          switch self {
            case .idleNormal(_, let time): return time
            case .walkNormal(_, let time): return time
            case .idleBounce(_, let time): return time
            case .walkBounce(_, let time): return time
          }
        }
        set {
          switch self {
            case .idleNormal: self = .idleNormal(animation, newValue)
            case .walkNormal: self = .walkNormal(animation, newValue)
            case .idleBounce: self = .idleBounce(animation, newValue)
            case .walkBounce: self = .walkBounce(animation, newValue)
          }
        }
      }
      
      var animation: Animation {
        get {
          switch self {
            case .idleNormal(let animation, _): return animation
            case .walkNormal(let animation, _): return animation
            case .idleBounce(let animation, _): return animation
            case .walkBounce(let animation, _): return animation
          }
        }
        set {
          switch self {
            case .idleNormal: self = .idleNormal(newValue, time)
            case .walkNormal: self = .walkNormal(newValue, time)
            case .idleBounce: self = .idleBounce(newValue, time)
            case .walkBounce: self = .walkBounce(newValue, time)
          }
        }
      }
      
      mutating func update(_ delta: Float) {
        self.time += delta
        if self.time >= self.animation.duration {
          self.time = 0
          self.animation.swap()
        }
      }
    }
    
    init(position: Point<Float>, state: State) {
      self.position = position
      self.state = state
    }
    
    var position: Point<Float>
    var state: State
    
    private var frameProgress: Float = 0
  }
}

extension SDL.Games.StinkyDuck {
  fileprivate enum GameState: CustomDebugStringConvertible {
    case uninitialized
    case loading
    case ready(SDL.Games.StinkyDuck)
    case gameOver(SDL.Games.StinkyDuck)
    indirect case pause(GameState)
    
    var debugDescription: String {
      switch self {
        case .uninitialized: return "uninitialized"
        case .loading: return "loading"
        case .ready: return "ready"
        case .gameOver: return "game over"
        case .pause: return "paused"
      }
    }
    
    fileprivate func update(with renderContext: SDL.Games.RenderContext<SDL.Games.StinkyDuck>) throws(SDL_Error) -> Void {
      guard case(.valid(let renderer, let game, let delta)) = renderContext  else {
        return
      }
      
      try updateFunc(renderer, game, delta)
      try renderer
        .clear(color: .gray)
        .pass(to: renderFunc, game)
        .present()
    }
    
    private var updateFunc: (any Renderer, SDL.Games.StinkyDuck, UInt64) throws(SDL_Error) -> Void {
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
            game[imageAsset] = try texture(SDL_SetTextureScaleMode, SDL_SCALEMODE_NEAREST)
          }
          
          /* The game is ready to begin... */
          game.gameState = .ready(game)
        }
          
        case .ready: return { renderer, game, delta in
          let deltaInSecs = Float(delta) / 10000000
          game.ducks = game.ducks.map({
            var duck = $0
            duck.state.update(deltaInSecs)
            return duck
          })
        }
          
        default: return { _, _ ,_ in
        }
      }
    }
    
    /// The rendering callback used for drawing the `GameState`.
    private var renderFunc: (_ renderer: any Renderer, _ game: SDL.Games.StinkyDuck) throws(SDL_Error) -> Void {
      switch self {
        case .ready: return { renderer, game in
          game.ducks.forEach {
            let player = $0
            let spriteSize: Size<Float> = [(32/192), (32/128)]
            let sourcePos: Point<Float> = [
              Float(player.state.animation.frame) * spriteSize.x,
              Float(player.state.animation.id) * spriteSize.y
            ]
            _ = try? renderer.draw(
              texture: game[.stinkDuckHero]
              , at: SDL_FPoint(player.position)
              , scaledBy: [2, 2]
              , textureRect: [sourcePos.x, sourcePos.y, spriteSize.x, spriteSize.y]
            )
          }
        }
        default: return { _, _ in
        }
      }
    }
  }
}

extension SDL.Games.StinkyDuck {
  fileprivate enum ImageAsset: String, CaseIterable {
    case stinkDuckHero = "Stink Duck (Hero)"
    
    var loadAsTransparent: Bool { true }
    
    var fileName: String {
      switch self {
        case .stinkDuckHero: return "stinky_duck_hero.bmp"
      }
    }
    
    static var allCases: [Self] {
      [
        .stinkDuckHero
      ]
    }
  }
}
