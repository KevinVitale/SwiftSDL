import CSDL2

public class PixelFormat: SDLPointer<PixelFormat>, SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_PixelFormat>) {
        SDL_FreeFormat(pointer)
    }
}

public extension PixelFormat {
    static func name(for format: UInt32) -> String {
        SDL_GetPixelFormatName(format).map(String.init)!
    }
    
    var name: String {
        SDL_GetPixelFormatName(self.pass(to: { $0.pointee.format })).map(String.init) ?? ""
    }
}
