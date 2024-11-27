open class DebugTextNode: SpriteNode<any Renderer> {
  public required init(_ label: String, text: String, color: SDL_Color = .black, position: Point<Float> = .zero) {
    super.init(label, position: position, size: text.debugTextSize(as: Float.self), color: color)
    self.text = text
  }
  
  public required init(_ label: String = "") {
    super.init(label, position: .zero, size: .zero, color: .black)
  }
  
  public required init(_ label: String = "", position: Point<Float> = .zero, size: Size<Float> = .zero, color: SDL_Color) {
    super.init(label, position: position, size: size, color: color)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  open var text: String = "" {
    didSet {
      size = text.debugTextSize(as: Float.self)
    }
  }

  override open func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try super.draw(graphics)
    
    guard !text.isEmpty else { return }
    try graphics.debug(text: text, position: position, color: color, scale: scale)
  }
}

extension Renderer {
  @discardableResult
  public func debug(text: String, position: Point<Float>, color fillColor: SDL_Color = .white, scale: Size<Float>) throws(SDL_Error) -> Self {
    let renderColor = try self.color.get()
    let renderScale = try self.scale.get()
    
    try self
      .set(color: fillColor)
      .set(scale: scale)
    
    guard SDL_RenderDebugText(pointer, position.x, position.y, text) else {
      throw SDL_Error.error
    }
    
    return try self
      .set(color: renderColor)
      .set(scale: renderScale)
  }
}
