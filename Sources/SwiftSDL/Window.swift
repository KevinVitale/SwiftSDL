import Clibsdl2

class Window {
    private let pointer: OpaquePointer;
    
    required init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    convenience init?(title: String = "", x: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), y: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), width: Int32, height: Int32, flags: SDL_WindowFlags...) {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = title.withCString({ SDL_CreateWindow($0, x, y, width, height, flags_) }) else {
            return nil
        }
        self.init(pointer: pointer)
    }
    
    /* TODO: Support `SDL_Error`, and `throw` instead. */
    convenience init?(renderer: inout Renderer!, width: Int32, height: Int32, flags: SDL_WindowFlags...) {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        
        var rendererPtr: OpaquePointer? = nil
        var windowPtr: OpaquePointer? = nil
        guard SDL_CreateWindowAndRenderer(width, height, flags_, &windowPtr, &rendererPtr) >= 0 else {
            return nil
        }
        
        renderer = Renderer(pointer: rendererPtr!)
        self.init(pointer: windowPtr!)
    }

    deinit {
        SDL_DestroyWindow(pointer)
    }

    func has(flags mask: UInt32) -> Bool{
        return (SDL_GetWindowFlags(pointer) & mask) != 0
    }
    
    var resizable: Bool {
        get { return has(flags: SDL_WINDOW_RESIZABLE.rawValue) }
        set { SDL_SetWindowResizable(pointer, .init(booleanLiteral: newValue)) }
    }
    
    var id: UInt32 {
        return SDL_GetWindowID(pointer)
    }
    
    var size: (width: Int32, height: Int32) {
        get {
            var w: Int32 = 0, h: Int32 = 0
            SDL_GetWindowSize(pointer, &w, &h)
            return (width: w, height: h)
        }
        set {
            SDL_SetWindowSize(pointer, newValue.width, newValue.height)
        }
    }
    
    var title: String {
        get {
            return String(cString: SDL_GetWindowTitle(pointer)!)
        }
        set {
            newValue.withCString { bytes in
                SDL_SetWindowTitle(pointer, bytes)
            }
        }
    }
    
    var surface: SDL_Surface? {
        return SDL_GetWindowSurface(pointer)?.pointee
    }
}
