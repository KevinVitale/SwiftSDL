import Clibsdl2

struct Renderer {
    let pointer: OpaquePointer
    
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
    
    func clear() {
        SDL_RenderClear(pointer)
    }
    func present() {
        SDL_RenderPresent(pointer)
    }
}

