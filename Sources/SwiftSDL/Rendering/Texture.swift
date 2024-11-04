@dynamicMemberLookup
public protocol Texture: SDLObjectProtocol where Pointer == UnsafeMutablePointer<SDL_Texture> { }

extension SDLObject<UnsafeMutablePointer<SDL_Texture>>: Texture { }
extension Unmanaged: Texture where Instance: Texture { }

extension SDLObject where Pointer == UnsafeMutablePointer<SDL_Texture> {
  static func unmanaged(_ pointer: Pointer) -> Unmanaged<SDLObject<Pointer>> {
    let managed = SDLObject(pointer, tag: .custom("texture"), destroy: SDL_DestroyTexture)
    return Unmanaged.passRetained(managed)
  }
}

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
  
  return SDLObject.unmanaged(pointer, tag: .custom("texture"), SDL_DestroyTexture)//.autorelease()
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
  
  public var blendMode: Result<SDL_BlendMode, SDL_Error> {
    Result {
      var blendMode: SDL_BlendMode = .zero
      try self(SDL_GetTextureBlendMode, .some(&blendMode))
      return blendMode
    }
    .mapError { $0 as! SDL_Error }
  }
  
  @discardableResult
  public func set(blendMode: SDL_BlendMode) throws(SDL_Error) -> Self {
    try self(SDL_SetTextureBlendMode, blendMode)
  }
}

extension Renderer {
  public func texture(from surface: any Surface) throws(SDL_Error) -> any Texture {
    guard case(.some(let pointer)) = try self(SDL_CreateTextureFromSurface, surface.pointer) else {
      throw SDL_Error.error
    }
    
    return SDLObject.unmanaged(pointer)//.autorelease()
  }
  
  public func texture(from bitmap: inout [UInt8]) throws(SDL_Error) -> any Texture {
    guard let srcPtr = SDL_IOFromMem(&bitmap, bitmap.count) else {
      throw SDL_Error.error
    }
    
    guard let pointer = SDL_LoadBMP_IO(srcPtr, true) else {
      throw SDL_Error.error
    }
    
    let surface = SDLObject.unmanaged(pointer)//.autorelease()
    return try self.texture(from: surface)
  }
}
