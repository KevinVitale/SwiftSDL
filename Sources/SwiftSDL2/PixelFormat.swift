import Foundation.NSThread
import CSDL2

public struct SDLPixelFormat: SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_PixelFormat>) {
        SDL_FreeFormat(pointer)
    }
}

public extension SDL { typealias PixelFormat = SDLPointer<SDLPixelFormat> }

extension SDLPointer where T == SDLPixelFormat {
}
