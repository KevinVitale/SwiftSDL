
extension SDL.Games {
  final class StinkyDuck: Game {
    private enum CodingKeys: CodingKey {
      case options
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Them ducks need a bath!"
    )
    
    static let name: String = "SwiftSDL Game: Stinky Duck"

    @OptionGroup
    var options: GameOptions
    
    private var spriteScale: Size<Float> = [2, 2]
    private var sprites: [SpriteAnimation<AnyAnimation>] = []
    
    private var gameState         : GameState = .uninitialized
    private var gameController    : GameController = .invalid
    private var gameTextures      : [ImageAsset : any Texture] = [:]

    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      try SDL_Init(.gamepad)
      
      let windowSize = try window.size(as: Float.self)
      let renderer = try window
        .createRenderer()
        .set(
          logicalSize: windowSize,
          presentation: .stretch
        )
      
      self.gameState = .loadTextures(renderer: renderer)
    }
    
    func onUpdate(window: any SwiftSDL.Window, _ delta: Uint64) throws(SwiftSDL.SDL_Error) {
      let deltaInSeconds = Float(delta) / 10_000_000
      try self.gameState.update(self, deltaInSeconds)
      try self.gameState.render(self)
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
      switch event.eventType {
        case .keyDown:
          switch event.key.key {
            case SDLK_RIGHT: break
            case SDLK_LEFT: break
            default: break
          }
        case .keyUp: break
        default: break
      }
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      self.gameState = .uninitialized
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
  fileprivate enum GameState {
    case uninitialized
    case loadTextures(renderer: any Renderer)
    case loadSprites(renderer: any Renderer, spriteScale: Size<Float>)
    case ready(renderer: any Renderer)
    
    fileprivate var update: (_ game: SDL.Games.StinkyDuck, _ deltaInSeconds: Float) throws(SDL_Error) -> Void {
      switch self {
        case .loadTextures(let renderer): return { game, _ in
          /* Load each image asset into the renderer (as a texture) */
          for imageAsset in ImageAsset.allCases {
            let surface = try Load(bitmap: imageAsset.fileName)
            let texture = try renderer.texture(
              from: surface,
              transparent: imageAsset.loadAsTransparent
            )
            game[imageAsset] = try texture(SDL_SetTextureScaleMode, SDL_SCALEMODE_NEAREST)
            game.gameState = .loadSprites(renderer: renderer, spriteScale: game.spriteScale)
          }
        }
        case .loadSprites(let renderer, let spriteScale): return { game, _ in
          let brownDucks = Duck.allCases
            .enumerated()
            .map({ index, state -> SDL.Games.SpriteAnimation<SDL.Games.AnyAnimation> in
              let texture   = game[.brownDuck]
              let animation = SDL.Games.AnyAnimation.state(state)
              return SDL.Games.SpriteAnimation(
                texture
                , animation: animation
                , position: [0, state.frameSize.y * Float(index)] * spriteScale
                , scale: spriteScale
              )
            })
          let yellowDucks = Duck.allCases
            .enumerated()
            .map({ index, state -> SDL.Games.SpriteAnimation<SDL.Games.AnyAnimation> in
              let texture   = game[.yellowDuck]
              let animation = SDL.Games.AnyAnimation.state(state)
              return SDL.Games.SpriteAnimation(
                texture
                , animation: animation
                , position: [state.frameSize.x, state.frameSize.y * Float(index)] * spriteScale
                , scale: spriteScale
              )
            })
          let knights = Knight.allCases
            .enumerated()
            .map({ index, state -> SDL.Games.SpriteAnimation<SDL.Games.AnyAnimation> in
              let texture   = game[.knight]
              let animation = SDL.Games.AnyAnimation.state(state)
              return SDL.Games.SpriteAnimation(
                texture
                , animation: animation
                , position: [1.75 * state.frameSize.x, state.frameSize.y / 1.5 * Float(index)] * spriteScale - [0, state.frameSize.y / 1.5]
                , scale: spriteScale
              )
            })
          let slimes = Slime.allCases
            .enumerated()
            .map({ index, state -> SDL.Games.SpriteAnimation<SDL.Games.AnyAnimation> in
              let texture   = game[.slimeBlob]
              let animation = SDL.Games.AnyAnimation.state(state)
              return SDL.Games.SpriteAnimation(
                texture
                , animation: animation
                , position: [3.25 * state.frameSize.x, state.frameSize.y * Float(index)] * spriteScale
                , scale: spriteScale
              )
            })
          let froggies = Froggy.allCases
            .enumerated()
            .map({ index, state -> SDL.Games.SpriteAnimation<SDL.Games.AnyAnimation> in
              let texture   = game[.froggy]
              let animation = SDL.Games.AnyAnimation.state(state)
              return SDL.Games.SpriteAnimation(
                texture
                , animation: animation
                , position: [2.05 * state.frameSize.x, state.frameSize.y * Float(index)] * spriteScale
                , scale: spriteScale
              )
            })
          game.sprites = brownDucks
          + yellowDucks
          + knights
          + slimes
          + froggies
          game.gameState = .ready(renderer: renderer)
        }
        case .ready: return { game, deltaInSeconds in
          game.sprites = game.sprites.map {
            var sprite = $0
            sprite.animate(deltaInSeconds)
            return sprite
          }
          
        }
        default: return { _, _ in }
      }
    }
    
    fileprivate var render: (_ game: SDL.Games.StinkyDuck) throws(SDL_Error) -> Void {
      switch self {
        case .ready(let renderer): return { game in
          try renderer
            .clear(color: .gray)
            .draw(sprites: game.sprites)
            .present()
        }
        default: return { _ in
        }
      }
    }
  }
}

extension SDL.Games.StinkyDuck {
  fileprivate enum ImageAsset: String, CaseIterable {
    case brownDuck  = "Brown Duck"
    case yellowDuck = "Yellow Duck"
    case slimeBlob  = "Slime Blob"
    case froggy     = "Froggy"
    case knight     = "Knight"

    var loadAsTransparent: Bool { true }
    
    var fileName: String {
      switch self {
        case .brownDuck:  return "stinky_duck_brown.bmp"
        case .yellowDuck: return "stinky_duck_yellow.bmp"
        case .slimeBlob:  return "slime_blob.bmp"
        case .froggy:     return "froggy.bmp"
        case .knight:     return "knight.bmp"
      }
    }
  }
}

extension SDL.Games.StinkyDuck {
  /// https://caz-creates-games.itch.io/ducky-3
  enum Duck: RawRepresentable, AnimationState, CaseIterable {
    enum Style { case normal; case bounce }
    
    var id: Int { rawValue }
    
    private var frames: Int {
      switch self {
        case .idle(let style):
          switch style {
            case .normal: return 2
            case .bounce: return 4
          }
        case .walk: return 6
      }
    }
    
    var frameSize: SwiftSDL.Size<Float> {
      [32, 32]
    }
    
    func nextFrame(after frame: Int) -> Int {
      guard frame < frames - 1 else {
        return 0
      }
      
      return frame + 1
    }
    
    func frameDuration(for frame: Int) -> Float {
      60 / Float(max(frames, 1))
    }
    
    static let `default`: Self = .idle(.normal)
    
    init?(rawValue: Int) {
      switch rawValue {
        case 0: self = .idle(.normal)
        case 1: self = .walk(.normal)
        case 2: self = .idle(.bounce)
        case 3: self = .walk(.bounce)
        default: return nil
      }
    }
    
    var rawValue: Int {
      switch self {
        case .idle(let style):
          switch style {
            case .normal: return 0
            case .bounce: return 2
          }
        case .walk(let style):
          switch style {
            case .normal: return 1
            case .bounce: return 3
          }
      }
    }
    
    case idle(Style)
    case walk(Style)
    
    static var allCases: [Self] {
      [
        .idle(.normal),
        .idle(.bounce),
        .walk(.normal),
        .walk(.bounce)
      ]
    }
  }
  
  /// https://caz-creates-games.itch.io/slime-blob
  enum Slime: Int, AnimationState, CaseIterable {
    var id: Int { rawValue }
    
    private var frames: Int {
      4
    }
    
    var frameSize: SwiftSDL.Size<Float> {
      [32, 32]
    }
    
    func nextFrame(after frame: Int) -> Int {
      guard frame < frames - 1 else {
        return 0
      }
      
      return frame + 1
    }
    
    func frameDuration(for frame: Int) -> Float {
      60 / Float(max(frames, 1))
    }
    
    static let `default`: Self = .idle
    
    case idle = 0
    case move
  }
  
  /// https://caz-creates-games.itch.io/froggy
  enum Froggy: Int, AnimationState, CaseIterable {
    var id: Int { rawValue }
    
    private var frames: Int {
      switch self {
        case .idle: return 4
        case .hop: return 7
        case .hurt: return 2
        case .attack: return 4
      }
    }
    
    var frameSize: SwiftSDL.Size<Float> {
      [64, 32]
    }
    
    func nextFrame(after frame: Int) -> Int {
      guard frame < frames - 1 else {
        return 0
      }
      
      return frame + 1
    }
    
    func frameDuration(for frame: Int) -> Float {
      60 / Float(max(frames, 1))
    }
    
    static let `default`: Self = .idle
    
    case idle = 0
    case hop
    case hurt
    case attack
  }
  
  /// https://caz-creates-games.itch.io/knight
  enum Knight: Int, AnimationState, CaseIterable {
    var id: Int { rawValue }
    
    private var frames: Int {
      switch self {
        case .walk: fallthrough
        case .attack: return 4
        default: return 1
      }
    }
      
    var frameSize: SwiftSDL.Size<Float> {
      [40, 40]
    }
    
    func nextFrame(after frame: Int) -> Int {
      guard frame < frames - 1 else {
        return 0
      }
      
      return frame + 1
    }
    
    func frameDuration(for frame: Int) -> Float {
      60 / Float(max(frames, 1))
    }

    static let `default`: Self = .idle
    
    case idle = 0
    case blink
    case walk
    case attack
    case hurt
  }
}
