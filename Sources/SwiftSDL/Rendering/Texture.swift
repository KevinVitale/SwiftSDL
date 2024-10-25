public final class TexturePtr: SDLPointer {
  public static func destroy(_ pointer:  UnsafeMutablePointer<SDL_Texture>) {
    SDL_DestroyTexture(pointer)
  }
}

@MainActor
public protocol Texture: SDLObjectProtocol where Pointer == TexturePtr { }

extension SDLObject<TexturePtr>: Texture { }

extension Texture {
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
