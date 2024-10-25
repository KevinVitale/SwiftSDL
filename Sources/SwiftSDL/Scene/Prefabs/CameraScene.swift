public final class CameraScene: BaseScene {
  public private(set) var camera: SDL_Camera? = nil
  
  public required init(_ label: String = "", size: Size<Float>, matching camera: SDL_Camera.MatchingCallback) throws(SDL_Error) {
    self.camera = try SDL_Camera.matching(camera)
    super.init(label, size: size)
  }
  
  public required init(_ label: String = "", size: Size<Float>, bgColor: SDL_Color = .gray, blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE) {
    fatalError("init(_:size:bgColor:blendMode:) has not been implemented")
  }
  
  public required init(_ label: String = "") {
    super.init(label)
  }
  
  public required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  public override func draw(_ surface: any Surface) throws(SDL_Error) {
    var rect: SDL_Rect! = nil
    
    if size != .zero {
      let bounds: SDL_FRect = [
        position.x, position.y,
        size.x, size.y
      ]
      rect = bounds.to(Int32.self)
    }
    
    try surface.clear(color: bgColor)
    
    if case(.success(let frame)) = camera?.frame, let frame = frame.0 {
      try frame(
        SDL_BlitSurfaceScaled,
        nil,
        surface.pointer,
        .some(&rect),
        SDL_SCALEMODE_NEAREST
      )
    }
  }
}
