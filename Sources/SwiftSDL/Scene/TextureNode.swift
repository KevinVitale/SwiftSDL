open class TextureNode: SceneNode {
  internal var _texture: (any Texture)!
  internal var _color: SDL_Color = .white
  internal var _size: Size<Float> = .zero
  
  public required init(_ label: String = "", with texture: any Texture, color: SDL_Color, size: Size<Float>) {
    super.init(label)
    self._texture = texture
    self._color = color
    self._size = size
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  @MainActor
  public convenience init(_ label: String = "", with surface: any Surface, using renderer: any Renderer) throws(SDL_Error) {
    let texture = try renderer.texture(from: surface)
    let size = try texture.size(as: Float.self)
    self.init(label, with: texture, color: .white, size: size)
  }
}
