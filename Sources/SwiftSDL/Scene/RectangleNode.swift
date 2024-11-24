open class RectangleNode<Graphics>: SpriteNode<Graphics> {
  public convenience init(_ label: String = "", size: Size<Float>, color: SDL_Color) {
    self.init(label)
    self.size = size
    self.color = color
  }
  
  public var size: Size<Float> = .zero
  public var color: SDL_Color = .white
  
  var rect: SDL_Rect {
    let rect: SDL_FRect = [
      position.x, position.y,
      size.x, size.y
    ]
    return rect.to(Int.self)
  }
  
  override open func draw(_ graphics: Graphics) throws(SDL_Error) {
    switch graphics {
      case let renderer as (any Renderer)?:
        try renderer?.fill(rects: rect.to(Float.self), color: color)
      case let surface as (any Surface)?:
        try surface?.fill(rects: rect, color: color)
      default: return
    }
  }
}
