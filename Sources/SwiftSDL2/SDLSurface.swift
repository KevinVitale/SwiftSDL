import CSDL2

public final class SDLSurface: SDLPointer<SDLSurface>, SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_Surface>) {
        SDL_FreeSurface(pointer)
    }
    
    func copyPixelFormat() -> SDLPixelFormat {
        self.pass { SDL_AllocFormat($0.pointee.format.pointee.format) }
            .map(SDLPixelFormat.init)!
    }
}
