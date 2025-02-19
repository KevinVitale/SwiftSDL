open class DebugTextNode: SpriteNode<any Renderer> {
  public enum TextAlignment {
    case left
    case centered
  }
  
  public required init(_ label: String, text: String, color: SDL_Color = .black, position: Point<Float> = .zero, textAlignment: TextAlignment = .left) {
    super.init(label, position: position, size: text.debugTextSize(as: Float.self), color: color)
    self.text = text
    self.textAlignment = textAlignment
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
  
  public var textAlignment: TextAlignment = .centered
  
  open var text: String = "" {
    didSet {
      size = text.debugTextSize(as: Float.self)
    }
  }
  
  public var origin: Point<Float> {
    switch textAlignment {
      case .left: return position - size
      case .centered: return position - size / 2
    }
  }

  override open func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try super.draw(graphics)
    
    guard !text.isEmpty else { return }
    
    try graphics.debug(text: text, position: origin, color: color, scale: scale)
  }
}
