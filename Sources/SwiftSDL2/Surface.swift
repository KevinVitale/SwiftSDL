import CSDL2

public class Surface: SDLPointer<Surface>, SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_Surface>) {
        SDL_FreeSurface(pointer)
    }
}

public extension Surface {
    func copyPixelFormat() -> PixelFormat {
        self.pass { SDL_AllocFormat($0.pointee.format.pointee.format) }
            .map(PixelFormat.init)!
    }
}
