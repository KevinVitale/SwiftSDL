public protocol SceneProtocol: SceneNode, DrawableNode {
  init(_ label: String, size: Size<Float>, bgColor: SDL_Color, blendMode: SDL_BlendMode)
  
  var size: Size<Float> { get set }
  var bgColor: SDL_Color { get set }
  var blendMode: SDL_BlendMode { get set }
  
  func load(_ graphics: Graphics) throws(SDL_Error)
  func update(at delta: Uint64) throws(SDL_Error)
  func handle(_ event: SDL_Event) throws(SDL_Error)
  func shutdown() throws(SDL_Error)
}

open class GameScene<Graphics>: SceneNode, SceneProtocol {
  public required init(_ label: String = "", size: Size<Float>, bgColor: SDL_Color = .gray, blendMode: SDL_BlendMode = .none) {
    self.bgColor = bgColor
    self.blendMode = blendMode
    self.size = size
    super.init(label)
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  public private(set) var window: (any Window)?
  
  public var size: Size<Float> = .zero
  
  public var bgColor: SDL_Color = .gray
  public var blendMode: SDL_BlendMode = .none
  
  open func load(_ graphics: Graphics) throws(SDL_Error) { /* no-op */ }
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
      default: try SDL_Error.set(throwing: "Unsupported graphics type: \(graphics)")
    }
  }
}

extension SceneNode {
  public var scene: (any SceneProtocol)? {
    parent.scene
  }
}

extension Renderer {
  @discardableResult
  public func draw<Scene: SceneProtocol>(scene: Scene, updateAt delta: Uint64) throws(SDL_Error) -> Self where Scene.Graphics == any Renderer {
    try scene.update(at: delta)
    return try clear(color: .white)
      .draw(node: scene)
      .present()
  }
}

extension Window {
  @discardableResult
  public func draw<Scene: SceneProtocol>(scene: Scene, updateAt delta: Uint64) throws(SDL_Error) -> some Window where Scene.Graphics == any Surface {
    let surface = try surface.get()
    try scene.update(at: delta)
    try surface.draw(node: scene)
    return try updateSurface()
  }
}
