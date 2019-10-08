import CSDL2
import CSDL2_Image

public typealias Texture = SDLPointer<SDLTexture>

public struct SDLTexture: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
}
