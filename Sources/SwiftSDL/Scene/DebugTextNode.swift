open class DebugTextNode: SpriteNode<any Renderer> {
  public convenience init(_ label: String, text: String, color: SDL_Color = .black) {
    self.init(label)
    self.text = text
    self.color = color
  }
  
  open var text: String = ""
  open var color: SDL_Color = .black
  
  override open func draw(_ graphics: any Renderer) throws(SDL_Error) {
    try super.draw(graphics)
    
    guard !text.isEmpty else { return }
    try graphics.debug(text: text, position: position, color: color)
  }
}
