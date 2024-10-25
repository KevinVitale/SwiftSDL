public final class RendererPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
    SDL_DestroyRenderer(pointer)
  }
}

@MainActor
public protocol Renderer: SDLObjectProtocol where Pointer == RendererPtr { }

extension SDLObject<RendererPtr>: Renderer { }

extension Renderer {
  public var name: Result<String, SDL_Error> {
    return self
      .resultOf(SDL_GetRendererName)
      .map({ String(cString: $0) })
  }

  @discardableResult
  public func set(blendMode: Flags.BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderDrawBlendMode, blendMode.rawValue)
  }
  
  @discardableResult
  public func set(color: SDL_Color) throws(SDL_Error) -> Self {
    let red = Float(color.r) / Float(UInt8.max)
    let green = Float(color.g) / Float(UInt8.max)
    let blue = Float(color.b) / Float(UInt8.max)
    let alpha = Float(color.a) / Float(UInt8.max)
    
    return try self(SDL_SetRenderDrawColorFloat, red, green, blue, alpha)
  }
  
  @discardableResult
  public func clear(color: SDL_Color? = nil) throws(SDL_Error) -> Self {
    if let color {
      try self.set(color: color)
    }
    return try self(SDL_RenderClear)
  }

  @discardableResult
  public func present() throws(SDL_Error) -> Self {
    try self(SDL_RenderPresent)
  }
  
  @discardableResult
  public func fill(rects: SDL_FRect..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: color)
  }
  
  @discardableResult
  public func fill(rects: [SDL_FRect], color: SDL_Color) throws(SDL_Error) -> Self {
    try self(
      SDL_RenderFillRects,
      rects.withUnsafeBufferPointer(\.baseAddress),
      Int32(rects.count)
    )
  }
  
  @discardableResult
  public func draw(texture: any Texture) throws(SDL_Error) -> Self {
    let size = try texture.size(as: Float.self)
    var rect: SDL_FRect = [
      0, 0,
      size.x, size.y
    ]

    return try self(SDL_RenderTexture, texture.pointer, nil, .some(&rect))
  }
}

extension Renderer {
  public var vsync: Result<Int32, SDL_Error> {
    var vsync: Int32 = 0
    return self
      .resultOf(SDL_GetRenderVSync, .some(&vsync))
      .map({ _ in vsync })
  }
  
  public var viewport: Result<Rect<Int32>, SDL_Error> {
    var rect = SDL_Rect()
    return self
      .resultOf(SDL_GetRenderViewport, .some(&rect))
      .map({ _ in [rect.x, rect.y, rect.w, rect.h] })
  }
  
  @discardableResult
  public func set(vsync: Int32) throws(SDL_Error) -> Self {
    try self(SDL_SetRenderVSync, vsync)
  }
}
