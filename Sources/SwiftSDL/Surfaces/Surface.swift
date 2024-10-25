
public final class SurfacePtr: SDLPointer {
  public static func destroy(_ pointer: UnsafeMutablePointer<SDL_Surface>) {
    SDL_DestroySurface(pointer)
  }
}

@MainActor
public protocol Surface: SDLObjectProtocol where Pointer == SurfacePtr { }

extension SDLObject<SurfacePtr>: Surface { }

extension Surface {
  @discardableResult
  public func clear(color: SDL_Color? = nil) throws(SDL_Error) -> Self {
    let bgColor = color ?? .black
    
    let red = Float(bgColor.r) / Float(UInt8.max)
    let green = Float(bgColor.g) / Float(UInt8.max)
    let blue = Float(bgColor.b) / Float(UInt8.max)
    let alpha = Float(bgColor.a) / Float(UInt8.max)
    
    return try self(SDL_ClearSurface, red, green, blue, alpha)
  }
  
  @discardableResult
  public func map(color: SDL_Color) throws(SDL_Error) -> Uint32 {
    try self(SDL_MapSurfaceRGBA, color.r, color.g, color.b, color.a)
  }
  
  @discardableResult
  public func flip(_ flip: SDL_FlipMode) throws(SDL_Error) -> Self {
    try self(SDL_FlipSurface, flip)
  }
  
  @discardableResult
  public func fill(rects: SDL_Rect..., color: SDL_Color) throws(SDL_Error) -> Self {
    try self.fill(rects: rects, color: color)
  }
  
  @discardableResult
  public func fill(rects: [SDL_Rect], color: SDL_Color) throws(SDL_Error) -> Self {
    try self(
      SDL_FillSurfaceRects,
      rects.withUnsafeBufferPointer(\.baseAddress),
      Int32(rects.count),
      try map(color: color)
    )
  }
  
  public func blit() {
  }
}

@discardableResult
public func SDL_Load(bitmap file: String, relativePath: String? = nil) throws(SDL_Error) -> any Surface {
  guard let pointer = SDL_LoadBMP(file) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer: pointer)
}

@discardableResult
public func SDL_Load(
  bitmap file: String,
  searchingBundles bundles: [Bundle] = Bundle.resourceBundles(),
  inDirectory directory: String? = nil) throws(SDL_Error) -> any Surface
{
  guard let filePath = bundles.compactMap({ bundle in
    bundle.path(
      forResource: file,
      ofType: nil,
      inDirectory: directory
    )
  }).first else {
    SDL_LoadBMP(nil)
    throw SDL_Error.error
  }
  
  guard let pointer = SDL_LoadBMP(filePath) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer: pointer)
}
