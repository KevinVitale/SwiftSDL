public protocol DrawableNode: SceneNode {
  associatedtype Graphics
  func draw(_ graphics: Graphics) throws(SDL_Error)
}

internal protocol RenderNode: DrawableNode where Graphics == any Renderer {
  var colorMod: SDL_Color { get set}
  var flipMode: SDL_FlipMode { get set }
  var blendMod: SDL_BlendMode { get set }
  var size: Size<Float> { get }
}

internal protocol SurfaceNode: DrawableNode where Graphics == any Surface {
  var colorMod: SDL_Color { get set}
  var flipMode: SDL_FlipMode { get set }
  var blendMod: SDL_BlendMode { get set }
  var size: Size<Float> { get }
}

extension Renderer {
  @discardableResult
  public func draw<Node: DrawableNode>(node: Node?) throws(SDL_Error) -> Self where Node.Graphics == (any Renderer) {
    guard let node = node else {
      return self
    }
    
    guard !node.isHidden else {
      return self
    }
    
    for child in node.children.sorted(by: { $0.zPosition < $1.zPosition }) {
      if let child = child as? any RenderNode {
        try self.draw(node: child)
      }
    }

    let renderScale = try self.scale.get()
    return try self
      .set(scale: node.scale)
      .pass(to: { try node.draw($0) })
      .set(scale: renderScale) as! Self
   }
}

extension Surface {
  @discardableResult
  public func draw<Node: DrawableNode>(node: Node?) throws(SDL_Error) -> Self where Node.Graphics == (any Surface) {
    guard let node = node else {
      return self
    }
    
    guard !node.isHidden else {
      return self
    }
    
    for child in node.children.sorted(by: { $0.zPosition < $1.zPosition }) {
      if let child = child as? any SurfaceNode {
        try self.draw(node: child)
      }
    }
    
    try node.draw(self)
    return self
  }
}
