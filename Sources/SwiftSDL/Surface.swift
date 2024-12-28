// MARK: - Protocol
@dynamicMemberLookup
public protocol Surface: SDLObjectProtocol where Pointer == UnsafeMutablePointer<SDL_Surface> { }

// MARK: - Extensions
extension SDLObject<UnsafeMutablePointer<SDL_Surface>>: Surface { }

// MARK: - Subscript
extension Surface {
  public subscript<T>(dynamicMember keyPath: KeyPath<Self.Pointer.Pointee, T>) -> T {
    self.pointer.pointee[keyPath: keyPath]
  }
  
  public subscript<T>(dynamicMember keyPath: KeyPath<SDL_PixelFormatDetails, T>) -> T? {
    guard let details = SDL_GetPixelFormatDetails(self.format) else {
      return nil
    }
    
    return details.pointee[keyPath: keyPath]
  }
}

// MARK: - Computed Properties
extension Surface {
  public var size: Size<Int32> {
    [self.w, self.h]
  }
  
  public var palette: Result<UnsafeMutablePointer<SDL_Palette>?, SDL_Error> {
    self.resultOf(SDL_GetSurfacePalette)
  }
}

// MARK: - Color Functions
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
}
  
// MARK: - Modes
extension Surface {
  @discardableResult
  public func flip(_ flip: SDL_FlipMode) throws(SDL_Error) -> Self {
    try self(SDL_FlipSurface, flip)
  }
}

// MARK: - Fill Rects
extension Surface {
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
}

// MARK: - Load Bitmaps
@discardableResult
public func SDL_Load(bitmap file: String, relativePath: String? = nil) throws(SDL_Error) -> some Surface {
  guard let pointer = SDL_LoadBMP(file) else {
    throw .error
  }
  
  return SDLObject(pointer, tag: .custom("surface"), destroy: SDL_DestroySurface)
}

@discardableResult
public func SDL_Load(
  bitmap file: String,
  searchingBundles bundles: [Bundle] = Bundle.resourceBundles(),
  inDirectory directory: String? = nil) throws(SDL_Error) -> some Surface
{
  guard let filePath = bundles.compactMap({ bundle in
    bundle.path(
      forResource: file,
      ofType: nil,
      inDirectory: directory
    )
  }).first else {
    SDL_LoadBMP(nil)
    throw .error
  }
  
  guard let pointer = SDL_LoadBMP(filePath) else {
    throw .error
  }
  
  return SDLObject(pointer, tag: .custom("surface"), destroy: SDL_DestroySurface)
}

extension SDL_PixelFormat {
  public var order: SDL_BitmapOrder {
    SDL_BitmapOrder(rawValue: (rawValue >> 20) & 0x0F)
  }
}
