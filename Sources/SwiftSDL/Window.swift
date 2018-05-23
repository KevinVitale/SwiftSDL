import Clibsdl2

class Window {
    private let pointer: OpaquePointer;
    
    required init(pointer: OpaquePointer) {
        self.pointer = pointer
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
}
