import Clibsdl2

class Window: WrappedPointer {
    /**
     Create a new `Window`.
     
     - parameter title: The title.
     - parameter x: The `x` position, in screen space.
     - parameter y: The `y` position, in screen space.
     - parameter width: The horizontal size.
     - parameter height: The vertical size.
     - parameter flags: Additional properties used when creating the window. See: `SDL_WindowFlags`.
     
     - returns: A new `Window`, or `nil`, if creating the window fails.
     */
    convenience init?(title: String = "", x: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), y: Int32 = Int32(SDL_WINDOWPOS_UNDEFINED_MASK), width: Int32, height: Int32, flags: SDL_WindowFlags...) {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = title.withCString({
            SDL_CreateWindow($0, x, y, width, height, flags_)
        }) else {
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

    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL_WindowFlags...) -> Bool{
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (SDL_GetWindowFlags(pointer) & mask) != 0
    }
    
    /**
     Set the user-resizable state of a window.
     
     This will add or remove the window's `SDL_WINDOW_RESIZABLE` flag and
     allow/disallow user resizing of the window. This is a no-op if the window's
     resizable state already matches the requested state.
     
     - note: You can't change the resizable state of a fullscreen window.
     */
    var resizable: Bool {
        get { return has(flags: SDL_WINDOW_RESIZABLE) }
        set { SDL_SetWindowResizable(pointer, .init(booleanLiteral: newValue)) }
    }
    
    /// Get the numeric ID of a window, for logging purposes.
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
    
    /**
     Get the SDL surface associated with the window.
     
     A new surface will be created with the optimal format for the window, if
     necessary. This surface will be freed when the window is destroyed.
     
     - note: You may not combine this with 3D or the rendering API on this window.
     */
    var surface: UnsafeMutablePointer<SDL_Surface>! {
        return SDL_GetWindowSurface(pointer)
    }
}
