import Foundation.NSThread
import CSDL2

public struct SDLSurface: SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_Surface>) {
        SDL_FreeSurface(pointer)
    }
}

public typealias Surface = SDLPointer<SDLSurface>

public extension SDLPointer where T == SDLSurface {
    static func surface(forWindow window: Window) -> Result<Surface, Error> {
        guard let surface = SDL_GetWindowSurface(window._pointer) else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(Self(pointer: surface))
    }
    
    func lock() -> Bool {
        SDL_LockSurface(_pointer) == -1 ? false : true
    }
    
    func unlock() {
        SDL_UnlockSurface(_pointer)
    }
}
