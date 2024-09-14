public protocol Scene: SceneNode {
  init(_ label: String, size: Size<Float>, bgColor: SDL_Color, blendMode: SDL_BlendMode)
  
  var size: Size<Float> { get set }
  var bgColor: SDL_Color { get set }
  var blendMode: SDL_BlendMode { get set }
  
  @MainActor func update(window: any Window, at delta: Tick) throws(SDL_Error)
}

open class BaseScene: SceneNode, Scene {
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
  
  public var size: Size<Float> = [0, 0]
  public var bgColor: SDL_Color = .gray
  public var blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE
  
  open func update(window: any Window, at delta: Tick) throws(SDL_Error) {
  }
}
