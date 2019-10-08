import Foundation.NSThread
import CSDL2

public typealias Surface = SDLPointer<SDLSurface>

public struct SDLSurface: SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_Surface>) {
        SDL_FreeSurface(pointer)
    }
}

public extension SDLPointer where T == SDLSurface {
    func copyPixelFormat() -> PixelFormat {
        self.pass { SDL_AllocFormat($0.pointee.format.pointee.format) }
            .map(PixelFormat.init)!
    }
}
