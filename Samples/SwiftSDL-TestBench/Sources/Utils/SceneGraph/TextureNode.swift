open class TextureNode: SceneNode, RenderNode {
  public private(set) var texture: (any Texture)!
  
  open var colorMod: SDL_Color = .white
  open var flipMode: SDL_FlipMode = .none
  open var blendMod: SDL_BlendMode = .none
  
  var size: Size<Float> = .zero
  
  public private(set) var textureRect: Rect<Float> = [0, 0, 1, 1]

  public required init(_ label: String = "", with texture: any Texture, size: Size<Float>) {
    super.init(label)
    self.texture = texture
    self.size = size
  }

  public convenience init(_ label: String = "", position: Point<Float> = .zero, with texture: any Texture) throws(SDL_Error) {
    self.init(label, with: texture, size: try texture.size(as: Float.self))
    self.position = position
  }
  
  public convenience init(_ label: String = "", position: Point<Float> = .zero, surface: any Surface, colorMod color: SDL_Color = .white, renderer: any Renderer) throws(SDL_Error) {
    let texture = try renderer.texture(from: surface, tag: label)
    let size = try texture.size(as: Float.self)
    self.init(label, with: texture, size: size)
    self.position = position
    self.colorMod = color
  }

  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }

  open func draw(_ graphics: any Renderer) throws(SDL_Error) {
    let dstPos = position
    let colorMod = try texture.colorMod.get()
    
    try graphics.draw(
      texture: texture.set(colorMod: colorMod),
      at: dstPos(as: SDL_FPoint.self),
      scaledBy: scale(as: SDL_FSize.self),
      angle: rotation.value,
      flip: flipMode
    )
  }
}
