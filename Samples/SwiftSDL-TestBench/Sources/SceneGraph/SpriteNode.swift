open class SpriteNode<Graphics>: SceneNode, DrawableNode {
  open var colorMod: SDL_Color = .white
  open var flipMode: SDL_FlipMode = .none
  open var blendMod: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  open var color: SDL_Color
  
  open internal(set) var size: Size<Float> = .zero

  public required init(_ label: String = "", position: Point<Float> = .zero, size: Size<Float> = .zero, color: SDL_Color) {
    self.color = color
    super.init(label)
    self.position = position
    self.size = size
  }
  
  public required init(_ label: String = "") {
    self.color = .black
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    self.color = .black
    try super.init(from: decoder)
  }
  
  open func draw(_ graphics: Graphics) throws(SDL_Error) { /* no-op */ }
}

extension SpriteNode: RenderNode where Graphics == any Renderer { }
extension SpriteNode: SurfaceNode where Graphics == any Surface { }
