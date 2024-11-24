open class SpriteNode<Graphics>: SceneNode, DrawableNode {
  open func draw(_ graphics: Graphics) throws(SDL_Error) {
  }
}

extension SpriteNode: RenderNode where Graphics == any Renderer { }
extension SpriteNode: SurfaceNode where Graphics == any Surface { }
