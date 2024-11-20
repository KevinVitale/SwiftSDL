public protocol DrawableNode: SceneNode {
  associatedtype Graphics
  func draw(_ graphics: Graphics) throws(SDL_Error)
}

internal protocol RenderNode: DrawableNode where Graphics == any Renderer { }
internal protocol SurfaceNode: DrawableNode where Graphics == any Surface { }

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
    
    let scale = try self.scale.get()
    
    return try self
      .set(scale: Float(node.scale))
      .draw(into: { try node.draw($0) })
      .callAsFunction(SDL_SetRenderScale, scale.0, scale.1) as! Self
  }
}

extension Surface {
  @discardableResult
  public func draw<Node: DrawableNode>(node: Node?) throws(SDL_Error) -> Self where Node.Graphics == (any Surface) {
    fatalError("\(#function) not implemented")
  }
}
