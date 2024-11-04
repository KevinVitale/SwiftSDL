public protocol SceneProtocol: SceneNode {
  init(_ label: String, size: Size<Float>, bgColor: SDL_Color, blendMode: SDL_BlendMode)
  
  @MainActor var window: (any Window)? { get}
  
  var size: Size<Float> { get set }
  var bgColor: SDL_Color { get set }
  var blendMode: SDL_BlendMode { get set }
  
  @MainActor func attach(to window: any Window) throws(SDL_Error)
  @MainActor func update(at delta: Tick) throws(SDL_Error)
  @MainActor func handle(_ event: SDL_Event) throws(SDL_Error)
  @MainActor func shutdown() throws(SDL_Error)
}

open class BaseScene<Graphics>: SceneNode, SceneProtocol {
  public required init(
    _ label: String = "",
    size: Size<Float>,
    bgColor: SDL_Color = .gray,
    blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE
  ) {
    self.size = size
    self.bgColor = bgColor
    self.blendMode = blendMode
    super.init(label)
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  public private(set) var window: (any Window)?
  
  public var size: Size<Float> = [0, 0]
  public var bgColor: SDL_Color = .gray
  public var blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  /// Subclasses must call `super.attach(to:)`.
  open func attach(to window: any Window) throws(SDL_Error) {
    self.window = window
  }
  
  open func update(at delta: Tick) throws(SDL_Error) {
  }
  
  open func handle(_ event: SDL_Event) throws(SDL_Error) {
  }
  
  open func shutdown() throws(SDL_Error) {
  }
  
  @MainActor
  open func draw(_ graphics: Graphics) throws(SDL_Error) {
    for child in children {
      if let child = child as? SpriteNode<Graphics> {
        try child.draw(graphics)
      }
    }
  }
}

extension SceneNode {
  public var scene: (any SceneProtocol)? {
    parent.scene
  }
}

