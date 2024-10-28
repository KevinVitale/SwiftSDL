public final class RendererPtr: SDLPointer {
  public static func destroy(_ pointer: OpaquePointer) {
    SDL_DestroyRenderer(pointer)
  }
}

@MainActor
public protocol Renderer: SDLObjectProtocol where Pointer == RendererPtr { }

extension SDLObject<RendererPtr>: Renderer { }

public func SDL_CreateRenderer<P: PropertyValue>(with properties: (String, value: P)..., window: (any Window)? = nil) throws(SDL_Error) -> some Renderer {
  try SDL_CreateRenderer(with: properties, window: window)
}

public func SDL_CreateRenderer<P: PropertyValue>(with properties: [(String, value: P)], window: (any Window)? = nil) throws(SDL_Error) -> some Renderer {
  let rendererProperties = SDL_CreateProperties()
  defer { rendererProperties.destroy() }
  
  for property in properties {
    guard rendererProperties.set(property.0, value: property.value) else {
      throw SDL_Error.error
    }
  }
  
  if var windowPointer = window?.pointer {
    rendererProperties.set(
      SDL_PROP_RENDERER_CREATE_WINDOW_POINTER,
      value: withUnsafeMutableBytes(of: &windowPointer, \.baseAddress)
    )
  }

  guard let texture = SDL_CreateRendererWithProperties(rendererProperties) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer: texture)
}

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
  
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  public func outputSize<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Int32(), height = Int32()
    guard case(.success) = self.resultOf(SDL_GetRenderOutputSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
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
  public func draw(texture: (any Texture)?, destinationRect dstRect: Rect<Float>? = nil) throws(SDL_Error) -> Self {
    guard let texture = texture else { return self }
      
    let size = try texture.size(as: Float.self)
    
    var rect: SDL_FRect! = nil
    switch dstRect {
      case let dstRect?:
        rect = [
          dstRect.lowHalf.x, dstRect.lowHalf.y,
          dstRect.highHalf.x, dstRect.highHalf.y
        ]
      default:
        rect = [
          0, 0,
          size.x, size.y
        ]
    }

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
