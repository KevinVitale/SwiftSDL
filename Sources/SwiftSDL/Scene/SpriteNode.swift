open class SpriteNode<Graphics>: SceneNode, DrawableNode {
  public var colorMod: SDL_Color = .white
  public var flipMode: SDL_FlipMode = .none
  public var blendMod: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  open func draw(_ graphics: Graphics) throws(SDL_Error) { /* no-op */ }
}

extension SpriteNode: RenderNode where Graphics == any Renderer { }
extension SpriteNode: SurfaceNode where Graphics == any Surface { }
