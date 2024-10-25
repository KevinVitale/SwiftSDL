public final class TexturePtr: SDLPointer {
  public static func destroy(_ pointer:  UnsafeMutablePointer<SDL_Texture>) {
    SDL_DestroyTexture(pointer)
  }
}

@MainActor
public protocol Texture: SDLObjectProtocol where Pointer == TexturePtr { }

extension SDLObject<TexturePtr>: Texture { }

extension Texture {
}

extension Renderer {
  public func texture(from surface: any Surface) throws(SDL_Error) {

  }
}