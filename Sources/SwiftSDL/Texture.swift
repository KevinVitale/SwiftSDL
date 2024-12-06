@dynamicMemberLookup
public protocol Texture: SDLObjectProtocol, Sendable where Pointer == UnsafeMutablePointer<SDL_Texture> { }

extension SDLObject<UnsafeMutablePointer<SDL_Texture>>: Texture { }

public func SDL_CreateTexture<P: PropertyValue>(with properties: (String, value: P)..., renderer: any Renderer) throws(SDL_Error) -> some Texture {
  try SDL_CreateTexture(with: properties, renderer: renderer)
}

public func SDL_CreateTexture<P: PropertyValue>(with properties: [(String, value: P)], renderer: any Renderer) throws(SDL_Error) -> some Texture {
  let textureProperties = SDL_CreateProperties()
  defer { textureProperties.destroy() }
  
  for property in properties {
    guard textureProperties.set(property.0, value: property.value) else {
      throw SDL_Error.error
    }
  }
  
  guard let pointer = SDL_CreateTextureWithProperties(renderer.pointer, textureProperties) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer, tag: .custom("texture"), destroy: SDL_DestroyTexture)
}

extension Texture {
  public subscript<T>(dynamicMember keyPath: KeyPath<SDL_Texture, T>) -> T {
    self.pointer.withMemoryRebound(to: SDL_Texture.self, capacity: 1) {
      $0.pointee[keyPath: keyPath]
    }
  }
  
  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: FixedWidthInteger {
    var width = Float(), height = Float()
    guard case(.success) = self.resultOf(SDL_GetTextureSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  public func size<T: SIMDScalar>(as type: T.Type) throws(SDL_Error) -> Size<T> where T: BinaryFloatingPoint {
    var width = Float(), height = Float()
    guard case(.success) = self.resultOf(SDL_GetTextureSize, .some(&width), .some(&height)) else {
      throw SDL_Error.error
    }
    return [T(width), T(height)]
  }
  
  public func size(as type: SDL_Size.Type) throws(SDL_Error) -> SDL_Size {
    return .init(try size(as: Int32.self))
  }
  
  public func size(as type: SDL_FSize.Type) throws(SDL_Error) -> SDL_FSize {
    return .init(try size(as: Float.self))
  }

  public var blendMode: Result<SDL_BlendMode, SDL_Error> {
    Result {
      var blendMode: SDL_BlendMode.RawValue = .zero
      try self(SDL_GetTextureBlendMode, .some(&blendMode))
      return .init(rawValue: blendMode) ?? .invalid
    }
    .mapError { $0 as! SDL_Error }
  }
  
  @discardableResult
  public func set(blendMode: SDL_BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetTextureBlendMode, blendMode.rawValue)
  }
  
  public var colorMod: Result<SDL_Color, SDL_Error> {
    var r: Uint8 = 0, g: Uint8 = 0, b: Uint8 = 0
    return self
      .resultOf(SDL_GetTextureColorMod, .some(&r), .some(&g), .some(&b))
      .map({ _ in SDL_Color(r: r, g: g, b: b, a: 255) })
  }
  
  @discardableResult
  public func set(alphaMod component: UInt8) throws(SDL_Error) -> Self {
    try self(SDL_SetTextureAlphaMod, component)
  }

  @discardableResult
  public func set(colorMod color: SDL_Color) throws(SDL_Error) -> Self {
    try self(SDL_SetTextureColorMod, color.r, color.g, color.b)
  }
  
  @discardableResult
  public func set(colorMod r: UInt8, _ g: UInt8, _ b: UInt8) throws(SDL_Error) -> Self {
    try self(SDL_SetTextureColorMod, r, g, b)
  }
  
  public var renderer: Result<any Renderer, SDL_Error> {
    self
      .resultOf(SDL_GetRendererFromTexture)
      .map({ SDLObject($0, tag: .custom("texture.renderer")) })
  }
  
  @discardableResult
  @available(*, deprecated, message: "Use `draw(texture:at:scaledBy:angle:flip:)` instead")
  public func draw(
    sourceRect: SDL_FRect? = nil,
    dstRect: SDL_FRect? = nil,
    angle: Double = 0,
    center: SDL_FPoint? = nil,
    flip: SDL_FlipMode = .none
  ) throws(SDL_Error) -> Self {
    let renderer = try renderer.get()
    let textureSize = try self.size(as: Float.self)
    var sourceRect: SDL_FRect? = sourceRect ?? nil
    var dstRect: SDL_FRect? = dstRect ?? [0, 0, textureSize.x, textureSize.y]
    var center: SDL_FPoint? = center ?? nil
    try renderer(
      SDL_RenderTextureRotated,
      pointer,
      sourceRect != nil ? .some(&sourceRect!) : nil,
      dstRect != nil ? .some(&dstRect!) : nil,
      angle,
      center != nil ? .some(&center!) : nil,
      flip
    )
    return self
  }
}

extension Renderer {
  @discardableResult
  public func draw(texture: (any Texture)?, at position: SDL_FPoint = .zero, scaledBy scale: SDL_FSize = .one, angle: Double = 0, textureRect: SDL_FRect = [0, 0, 1, 1], flip: SDL_FlipMode = .none) throws(SDL_Error) -> Self {
    guard let texture = texture else {
      return self
    }
    
    let textureSize = try texture.size(as: Float.self)
    
    let sourceRectX = 0 + (textureSize.x * textureRect[0])
    let sourceRectY = 0 + (textureSize.y * textureRect[1])
    let sourceRectW = (textureSize.x * textureRect[2])
    let sourceRectH = (textureSize.y * textureRect[3])
    var sourceRect: SDL_FRect = [sourceRectX, sourceRectY, sourceRectW, sourceRectH]
    
    let destRectX = position.x
    let destRectY = position.y
    let destRectW = scale.x * textureSize.x
    let destRectH = scale.y * textureSize.y
    var destRect: SDL_FRect = [destRectX, destRectY, destRectW, destRectH]
    
    return try self(SDL_RenderTextureRotated, texture.pointer, .some(&sourceRect), .some(&destRect), angle, nil, flip)
  }
  
  public func texture(from surface: any Surface, transparent: Bool = false, tag: String? = nil) throws(SDL_Error) -> any Texture {
    if transparent, let bpp = surface.bits_per_pixel, let pixels = surface.pixels {
      if try surface.palette.get() != nil {
        let mask: UInt8 = (1 << bpp) - 1
        if surface.format.order == SDL_BITMAPORDER_4321 {
          let key = pixels.load(as: UInt8.self) & mask
          try surface(SDL_SetSurfaceColorKey, true, UInt32(key))
        }
        else {
          let key = pixels.load(as: UInt8.self) >> (8 - bpp) & mask
          try surface(SDL_SetSurfaceColorKey, true, UInt32(key))
        }
      }
      else {
        switch surface.bits_per_pixel ?? .zero {
          case 15: print("\(#function) -- BPP: 15")
            let key = UInt32(pixels.load(as: UInt8.self)) & 0x00007FFF
            try surface(SDL_SetSurfaceColorKey, true, key)
          case 16: print("\(#function) -- BPP: 16")
            let key = UInt32(pixels.load(as: UInt16.self))
            try surface(SDL_SetSurfaceColorKey, true, key)
          case 24: print("\(#function) -- BPP: 24")
            let key = UInt32(pixels.load(as: UInt32.self)) & 0x00FFFFFF
            try surface(SDL_SetSurfaceColorKey, true, key)
          case 32: print("\(#function) -- BPP: 32")
            let key = UInt32(pixels.load(as: UInt32.self))
            try surface(SDL_SetSurfaceColorKey, true, key)
          default: ()
        }
      }
    }

    guard case(.some(let pointer)) = try self(SDL_CreateTextureFromSurface, surface.pointer) else {
      throw .error
    }
    
    
    return SDLObject(pointer, tag: .custom(tag ?? "texture (from surface)"), destroy: SDL_DestroyTexture)
  }
  
  public func texture(from bitmap: inout [UInt8], transparent: Bool = false, tag: String? = nil) throws(SDL_Error) -> any Texture {
    guard let srcPtr = SDL_IOFromMem(&bitmap, bitmap.count) else {
      throw .error
    }
    
    guard let pointer = SDL_LoadBMP_IO(srcPtr, true) else {
      throw .error
    }
    
    let surface: any Surface = SDLObject(pointer, tag: .custom(tag ?? "surface (bitmap)"), destroy: SDL_DestroySurface)
    return try self.texture(from: surface, transparent: transparent, tag: tag)
  }
}
