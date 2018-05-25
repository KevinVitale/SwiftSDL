import Clibsdl2

class Renderer {
    /// Pointer returned by SDL2.
    private let pointer: OpaquePointer
    
    /**
     */
    required init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    deinit {
        SDL_DestroyRenderer(pointer)
    }
    
    var drawColor: SDL_Color {
        get {
            var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 0
            SDL_GetRenderDrawColor(pointer, &r, &g, &b, &a)
            return SDL_Color(r: r, g: g, b: b, a: a)
        }
        set {
            SDL_SetRenderDrawColor(pointer, newValue.r, newValue.g, newValue.b, newValue.a)
        }
    }
    
    var outputSize: (width: Int32, height: Int32) {
        var w: Int32 = 0, h: Int32 = 0
        SDL_GetRendererOutputSize(pointer, &w, &h)
        return (width: w, height: h)
    }

    /**
     */
    func clear() {
        SDL_RenderClear(pointer)
    }
    
    /**
     */
    func present() {
        SDL_RenderPresent(pointer)
    }
    
    func texture(access: SDL_TextureAccess = SDL_TEXTUREACCESS_STATIC, width: Int32, height: Int32) -> OpaquePointer! {
        return SDL_CreateTexture(pointer, UInt32(SDL_PIXELFORMAT_RGBA8888), Int32(access.rawValue), width, height)
    }
}
