extension SDL.Games {
  @dynamicMemberLookup
  @propertyWrapper
  struct SpriteAnimation<State: AnimationState> {
    init(_ wrappedValue: (any Texture)?, animation state: State, position: Point<Float> = .zero, scale: Size<Float> = .one, speed: Float = 1) {
      self.wrappedValue = wrappedValue
      self.state = state
      self.speed = speed
      self.position = position
      self.scale = scale
    }
    
    private var currentFrame: Int = 0
    private var currentTime: Float = 0
    
    var frameRate: Float = 1
    
    var properties = SceneProperties()

    var state: State {
      didSet { reset() }
    }
    
    weak var wrappedValue: (any Texture)?
    
    private mutating func reset() {
      self.currentFrame = 0
      self.currentTime = 0
    }
    
    mutating func animate(_ deltaInSeconds: Float) {
      self.currentTime += deltaInSeconds * self.frameRate
      if self.currentTime >= self.state.frameDuration(for: currentFrame) {
        self.currentTime = 0
        self.currentFrame = self.state.nextFrame(after: currentFrame)
      }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
      state[keyPath: keyPath]
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<SceneProperties, T>) -> T {
      get { properties[keyPath: keyPath] }
      set { properties[keyPath: keyPath] = newValue }
    }
    
    func draw(_ renderer: any Renderer) throws(SDL_Error) -> Void {
      guard let texture = wrappedValue else {
        return
      }
      
      let textureSize = try texture.size(as: Float.self)
      let spriteSize: Size<Float> = self.frameSize / textureSize
      
      let sourcePos: Point<Float> = [
        Float(currentFrame) * spriteSize.x,
        Float(self.id) * spriteSize.y
      ]
      
      let sourceRect: SDL_FRect = [
        sourcePos.x, sourcePos.y,
        spriteSize.x, spriteSize.y
      ]
      
      try renderer.draw(
        texture: texture
        , at: SDL_FPoint(self.position)
        , scaledBy: SDL_FSize(self.scale)
        , textureRect: sourceRect
      )
    }
  }
}

extension SDL.Games {
  struct SceneProperties {
    var speed: Float = 1
    var position: Point<Float> = .zero
    var scale: Size<Float> = .one
  }
}

extension Renderer {
  func draw<State: AnimationState>(sprite animation: SDL.Games.SpriteAnimation<State>?) throws(SDL_Error) -> some Renderer {
    guard let animation = animation else { return self }
    try self.pass(to: animation.draw(_:))
    return self
  }
}
