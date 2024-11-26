open class SpriteNode<Graphics>: SceneNode, DrawableNode {
  open var colorMod: SDL_Color = .white
  open var flipMode: SDL_FlipMode = .none
  open var blendMod: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  open var color: SDL_Color = .white
  
  public internal(set) override var size: Size<Float> {
    get { super.size }
    set { super.size = newValue }
  }

  public required init(_ label: String = "", position: Point<Float> = .zero, size: Size<Float> = .zero, color: SDL_Color) {
    super.init(label)
    self.position = position
    self.color = color
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  open func draw(_ graphics: Graphics) throws(SDL_Error) { /* no-op */ }
  
  public func contains(point: Point<Float>) -> Bool {
    var position: SDL_FPoint = [
      position.x, position.y,
    ]
    var rect: SDL_FRect = [
      position.x, position.y,
      size.x, size.y
    ]
    return SDL_PointInRectFloat(.some(&position), .some(&rect))
  }
}

extension SpriteNode: RenderNode where Graphics == any Renderer { }
extension SpriteNode: SurfaceNode where Graphics == any Surface { }
