open class RectangleNode<Graphics>: SpriteNode<Graphics> {
  public override var size: Size<Float> {
    get { super.size }
    set { super.size = newValue }
  }

  override open func draw(_ graphics: Graphics) throws(SDL_Error) {
    let rect: SDL_FRect = [
      position.x, position.y,
      size.x, size.y
    ]
    
    switch graphics {
      case let renderer as (any Renderer):
        try renderer.fill(rects: rect, color: color)
      case let surface as (any Surface):
        try surface.fill(rects: rect.to(Int.self), color: color)
      default: return
    }
  }
}
