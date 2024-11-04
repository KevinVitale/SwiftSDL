open class SpriteNode<Graphics>: SceneNode {
  @MainActor
  open func draw(_ graphics: Graphics) throws(SDL_Error) {
  }
}

public typealias SpriteNodeRendered = SpriteNode<any Renderer>
public typealias SpriteNodeSurface = SpriteNode<any Surface>
