import CSDL2
import CSDL2_Image
import Foundation.NSThread

public typealias Texture = SDLPointer<SDLTexture>

public struct SDLTexture: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
}
