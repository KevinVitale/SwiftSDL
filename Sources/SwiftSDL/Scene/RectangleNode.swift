open class RectangleNode<Graphics>: SpriteNode<Graphics> {
  var rect: SDL_Rect {
    let rect: SDL_FRect = [
      position.x, position.y,
      size.x, size.y
    ]
    return rect.to(Int.self)
  }
  
  public override var size: Size<Float> {
    get { super.size }
    set { super.size = newValue }
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
