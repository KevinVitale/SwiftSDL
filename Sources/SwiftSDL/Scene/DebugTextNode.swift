open class DebugTextNode: SpriteNode<any Renderer> {
  public convenience init(_ label: String, text: String, color: SDL_Color = .black, position: Point<Float> = .zero) {
    self.init(label)
    self.text = text
    self.color = color
    self.position = position
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
