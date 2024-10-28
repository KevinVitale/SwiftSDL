public final class TexturePtr: SDLPointer {
  public static func destroy(_ pointer:  UnsafeMutablePointer<SDL_Texture>) {
    SDL_DestroyTexture(pointer)
  }
}

@dynamicMemberLookup
public protocol Texture: SDLObjectProtocol where Pointer == TexturePtr { }

extension SDLObject<TexturePtr>: Texture { }

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
  
  guard let texture = SDL_CreateTextureWithProperties(renderer.pointer, textureProperties) else {
    throw SDL_Error.error
  }
  
  return SDLObject(pointer: texture)
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
}

extension Renderer {
  public func texture(from surface: any Surface) throws(SDL_Error) -> any Texture{
    guard case(.some(let pointer)) = try self(SDL_CreateTextureFromSurface, surface.pointer) else {
      throw SDL_Error.error
    }
    
    return SDLObject(pointer: pointer)
  }
}
