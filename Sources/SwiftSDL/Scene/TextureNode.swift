open class TextureNode: SceneNode {
  internal var _texture: (any Texture)!
  internal var _size: Size<Float> = .zero
  
  public required init(_ label: String = "", with texture: any Texture, size: Size<Float>) {
    super.init(label)
    self._texture = texture
    self._size = size
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  @MainActor
  public convenience init(_ label: String = "", position: Point<Float> = .zero, surface: any Surface, colorMod color: SDL_Color = .white, renderer: any Renderer) throws(SDL_Error) {
    let texture = try renderer.texture(from: surface, tag: label)
    let size = try texture.size(as: Float.self)
    self.init(label, with: texture, size: size)
    self.position = position
    try texture.set(colorMod: color)
  }
}

extension Renderer {
  @discardableResult
  public func draw(node: TextureNode?) throws(SDL_Error) -> Self {
    guard let node = node else {
      return self
    }
    
    guard !node.isHidden else {
      return self
    }

    for child in node.children.sorted(by: { $0.zPosition < $1.zPosition }) {
      if let child = child as? TextureNode {
        try self.draw(node: child)
      }
    }
    
    let scale = try self.scale.get()
    
    return try self
      .set(scale: Float(node.scale))
      .draw(texture: node._texture, position: node.position)
      .callAsFunction(SDL_SetRenderScale, scale.0, scale.1)
  }
}
