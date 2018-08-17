import Clibsdl2

extension SDL_RendererInfo
{
    public var label: String {
        return String(cString: name)
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL_RendererFlags...) -> Bool{
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
}

/**
 [Official Documentation](https://wiki.libsdl.org/CategoryRender)
 */
class Renderer: WrappedPointer
{
    /**
     Create a 2D rendering context for a window.
     
     - parameter window: The window where rendering is displayed.
     - parameter index:  The index of the rendering driver to initialize, or -1
                         to initialize the first one supporting the requested
                         flags.
     - parameter flags:   Flags specifying attributes of the newly created
                         renderer.
     */
    convenience init?(window: Window, driver index: Int = 0, flags: SDL_RendererFlags...) {
        let flags_: UInt32 = flags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = SDL_CreateRenderer(window.pointer, Int32(index), flags_) else {
            return nil
        }
        self.init(pointer: pointer)
    }
    
    /**
     Create a 2D software rendering context for a surface.
     
     - parameter surface: The surface where rendering is done.
     - returns: A valid rendering software context.
     */
    convenience init(surface: UnsafeMutablePointer<SDL_Surface>!) throws {
        guard let pointer = SDL_CreateSoftwareRenderer(surface) else {
            throw Error.error
        }
        self.init(pointer: pointer)
    }
    
    /**
     */
    override func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
    
}

extension Renderer
{
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

extension Renderer
{
    var blendingMode: SDL_BlendMode {
        get {
            var blendMode: SDL_BlendMode = SDL_BLENDMODE_NONE
            SDL_GetRenderDrawBlendMode(pointer, &blendMode)
            return blendMode
        } set {
            SDL_SetRenderDrawBlendMode(pointer, blendingMode)
        }
    }
    
    /**
     Get the current render target or NULL for the default render target.
     
     - note: When setting the targeted texture, the texture must be created with
             the `SDL_TEXTUREACCESS_TARGET` flag, or be `nil` for the default
             render target
     */
    var target: Texture? {
        get {
            guard let pointer = SDL_GetRenderTarget(pointer) else {
                return nil
            }
            return Texture(pointer: pointer)
        }
        set {
            guard driverInfo.has(flags: SDL_RENDERER_TARGETTEXTURE) else {
                return
            }
            SDL_SetRenderTarget(pointer, newValue?.pointer)
        }
    }
    
    /**
     Get information about a rendering context.
     */
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
     Get the output size in pixels of a rendering context.
     */
    var outputtedSize: (width: Int32, height: Int32) {
        var w: Int32 = 0
          , h: Int32 = 0
        SDL_GetRendererOutputSize(pointer, &w, &h)
        return (width: w, height: h)
    }
}

extension Renderer
{
    @available(OSX 10.11, *)
    var metalLayer: UnsafeMutableRawPointer? {
        let rawPointer = SDL_RenderGetMetalLayer(pointer)
        return rawPointer
    }
}

extension Renderer
{
    enum Draw {
        case point(SDL_Point)
        case points([SDL_Point])
        case line
        
        fileprivate func render(_ renderer: Renderer) {
            switch self {
            case .point(let point):
                return Draw.points([point]).render(renderer)
            case .points(let points):
                SDL_RenderDrawPoints(renderer.pointer, points, Int32(points.count))
            default: ()
            }
        }
    }
    
    func draw(_ draw: Draw, color: SDL_Color = SDL_Color()) {
        let previousColor = drawingColor
        drawingColor = color
        draw.render(self)
        drawingColor = previousColor
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
     Update the screen with rendering performed.
     */
    func present() {
        SDL_RenderPresent(pointer)
    }
}
