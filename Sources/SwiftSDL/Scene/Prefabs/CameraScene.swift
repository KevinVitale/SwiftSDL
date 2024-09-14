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
  
  public override func update(window: any Window, at delta: Tick) throws(SDL_Error) {
    try _draw(try window.surface.get())
    try window.set(SDL_UpdateWindowSurface)
  }
  
  @MainActor private func _draw(_ surface: any Surface) throws(SDL_Error) {
    try surface.clear(color: bgColor)
    
    if case(.success(let frame)) = camera?.frame, let frame = frame.0 {
      SDL_BlitSurfaceScaled(frame.pointer, nil, surface.pointer, nil, SDL_SCALEMODE_NEAREST)
    }
  }
}
