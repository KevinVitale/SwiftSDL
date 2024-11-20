public protocol SceneProtocol: SceneNode, DrawableNode {
  init(_ label: String, size: Size<Float>, bgColor: SDL_Color, blendMode: SDL_BlendMode)
  
  var window: (any Window)? { get}
  
  var size: Size<Float> { get set }
  var bgColor: SDL_Color { get set }
  var blendMode: SDL_BlendMode { get set }
  
  func attach(to window: any Window) throws(SDL_Error)
  func update(at delta: Uint64) throws(SDL_Error)
  func handle(_ event: SDL_Event) throws(SDL_Error)
  func shutdown() throws(SDL_Error)
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
  
  deinit {
    print(#function)
    removeAllChildren()
  }
  
  public private(set) var window: (any Window)?
  
  public var size: Size<Float> = [0, 0]
  public var bgColor: SDL_Color = .gray
  public var blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  /// Subclasses must call `super.attach(to:)`.
  open func attach(to window: any Window) throws(SDL_Error) {
    self.window = window
  }
  
  open func update(at delta: Uint64) throws(SDL_Error) { /* no-op */ }
  open func handle(_ event: SDL_Event) throws(SDL_Error) { /* no-op */ }
  
  open func shutdown() throws(SDL_Error) {
    self.removeAllChildren()
  }
  
  public final func draw(_ graphics: Graphics) throws(SDL_Error) {
    switch graphics {
      case let renderer as (any Renderer)?:
        try renderer?.clear(color: bgColor)
        for child in children.sorted(by: { $0.zPosition < $1.zPosition })  {
          if let child = child as? any RenderNode {
            try renderer?.draw(node: child)
          }
        }
      case let surface as (any Surface)?:
        try surface?.clear(color: bgColor)
        for child in children.sorted(by: { $0.zPosition < $1.zPosition })  {
          if let child = child as? any SurfaceNode {
            try surface?.draw(node: child)
          }
        }
      default:
        fatalError("Unsupported graphics type: \(graphics)")
    }
  }
}

extension SceneNode {
  public var scene: (any SceneProtocol)? {
    parent.scene
  }
}
