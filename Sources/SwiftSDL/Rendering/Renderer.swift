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
    do {
      let name = try self(SDL_GetRendererName)
      return .success(String(cString: name))
    }
    catch {
      return .failure(error)
    }
  }
  
  @discardableResult
  public func clear(color: SDL_Color? = nil) throws(SDL_Error) -> Self {
    if let color {
      let red = Float(color.r) / Float(UInt8.max)
      let green = Float(color.g) / Float(UInt8.max)
      let blue = Float(color.b) / Float(UInt8.max)
      let alpha = Float(color.a) / Float(UInt8.max)
      try self(SDL_SetRenderDrawColorFloat, red, green, blue, alpha)
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
}
