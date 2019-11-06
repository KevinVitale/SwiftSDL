import CSDL2

public final class SDLPixelFormat: SDLPointer<SDLPixelFormat>, SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_PixelFormat>) {
        SDL_FreeFormat(pointer)
    }
    
    public static func name(for format: UInt32) -> String {
        SDL_GetPixelFormatName(format).map(String.init)!
    }
    
    public var name: String {
        SDL_GetPixelFormatName(self.pass(to: { $0.pointee.format })).map(String.init) ?? ""
    }
}
