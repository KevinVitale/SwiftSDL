import CSDL2

public typealias Texture = SDLPointer<SDLTexture>

public struct SDLTexture: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
}
