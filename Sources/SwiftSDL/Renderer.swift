import Clibsdl2

extension SDL_RendererInfo {
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL_RendererFlags...) -> Bool{
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
}

class Renderer: WrappedPointer {
    /**
     */
    override func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
}

extension Renderer {
    /**
     */
    convenience init?(window: Window, driver index: Int = 0, flags: SDL_RendererFlags...) {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = SDL_CreateRenderer(window.pointer, Int32(index), flags_) else {
            return nil
        }
        self.init(pointer: pointer)
    }
}

extension Renderer {
    /**
     Get the number of 2D rendering drivers available for the current display.
     
     A render driver is a set of code that handles rendering and texture
     management on a particular display. Normally there is only one, but some
     drivers may have several available with different capabilities.
     */
    static var driverCount: Int {
        return Int(SDL_GetNumRenderDrivers())
    }
    
    /**
     Returns info for a the driver at a specific index.
     
     **Example:**
     ```
     (0..<Renderer.driverCount)
        .compactMap { Renderer.driverInfo($0) }
        .forEach {
            print(String(cString: $0.name).uppercased())
            print(($0.flags & SDL_RENDERER_ACCELERATED.rawValue) > 0)
            print(($0.flags & SDL_RENDERER_PRESENTVSYNC.rawValue) > 0)
            print(($0.flags & SDL_RENDERER_SOFTWARE.rawValue) > 0)
            print(($0.flags & SDL_RENDERER_TARGETTEXTURE.rawValue) > 0)
    }
     ```
     
     - parameter index: The index of the driver being queried.
     */
    static func driverInfo(_ index: Int) -> SDL_RendererInfo? {
        var info = SDL_RendererInfo()
        guard SDL_GetRenderDriverInfo(Int32(index), &info) >= 0 else {
            return nil
        }
        return info
    }
}

extension Renderer {
    var driverInfo: SDL_RendererInfo {
        var info = SDL_RendererInfo()
        SDL_GetRendererInfo(pointer, &info)
        return info
    }
    
    /**
     Get the color used for drawing operations (Rect, Line and Clear).
     */
    var drawingColor: SDL_Color {
        get {
            var r: UInt8 = 0
              , g: UInt8 = 0
              , b: UInt8 = 0
              , a: UInt8 = 0
            SDL_GetRenderDrawColor(pointer, &r, &g, &b, &a)
            return SDL_Color(r: r, g: g, b: b, a: a)
        }
        set {
            SDL_SetRenderDrawColor(pointer, newValue.r, newValue.g, newValue.b, newValue.a)
        }
    }

    /**
     */
    var outputtedSize: (width: Int32, height: Int32) {
        var w: Int32 = 0
          , h: Int32 = 0
        SDL_GetRendererOutputSize(pointer, &w, &h)
        return (width: w, height: h)
    }

    /**
     Clear the current rendering target with the drawing color
     
     This function clears the entire rendering target, ignoring the viewport and
     the clip rectangle.
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
