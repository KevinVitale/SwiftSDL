import Foundation.NSThread
import CSDL2
import QuartzCore.CAMetalLayer

public struct SDLRenderer: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
}


public extension SDL { typealias Renderer = SDLPointer<SDLRenderer> }

public extension SDLPointer where T == SDLRenderer {
    typealias RendererInfo = SDL_RendererInfo
    
    struct RenderFlags: OptionSet {
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlags.RawValue
        
        public static let hardwareAcceleration = RenderFlags(rawValue: SDL_RENDERER_ACCELERATED.rawValue)
        public static let softwareRendering    = RenderFlags(rawValue: SDL_RENDERER_SOFTWARE.rawValue)
        public static let targetTexturing      = RenderFlags(rawValue: SDL_RENDERER_TARGETTEXTURE.rawValue)
        public static let verticalSync         = RenderFlags(rawValue: SDL_RENDERER_PRESENTVSYNC.rawValue)
    }
    
    struct Flip: OptionSet {
        public init(rawValue: SDL_RendererFlip.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlip.RawValue
        
        public static let none       = Flip(rawValue: SDL_FLIP_NONE.rawValue)
        public static let vertical   = Flip(rawValue: SDL_FLIP_VERTICAL.rawValue)
        public static let horizontal = Flip(rawValue: SDL_FLIP_HORIZONTAL.rawValue)
    }
    
    static var availableRenderers: [SDL_RendererInfo] {
        return (0..<availableRendererCount).compactMap { rendererInfo($0) }
    }
    
    /**
     Get the number of rendering drivers available for the current display.
     
     A render driver is a set of code that handles rendering and texture
     management on a particular display. Normally there is only one, but some
     drivers may have several available with different capabilities.
     */
    static var availableRendererCount: Int {
        return Int(SDL_GetNumRenderDrivers())
    }
    
    /**
     Returns info for a the driver at a specific index.
     
     **Example:**
     ```
     (0..<SDLRenderer.availableRendererCount)
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
    private static func rendererInfo(_ index: Int) -> SDL_RendererInfo? {
        var info = SDL_RendererInfo()
        guard SDL_GetRenderDriverInfo(Int32(index), &info) >= 0 else {
            return nil
        }
        return info
    }

    convenience init(window: SDL.Window, driver index: Int = -1, flags renderFlags: RenderFlags...) throws {
        let flags: UInt32 = renderFlags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = SDL_CreateRenderer(window._pointer, Int32(index), flags) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    /**
     Create a
     */
    convenience init(withSurfaceFromWindow window: SDL.Window) throws {
        let surface = try window.surface.get()._pointer
        
        guard let pointer = SDL_CreateSoftwareRenderer(surface) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        
        self.init(pointer: pointer)
    }
    
    func drawingColor() -> Result<SDL_Color, Error> {
        var r: UInt8 = 0
          , g: UInt8 = 0
          , b: UInt8 = 0
          , a: UInt8 = 0
        
        switch SDL_GetRenderDrawColor(_pointer, &r, &g, &b, &a) {
        case -1:
            return .failure(SDLError.error(Thread.callStackSymbols))
        default:
            return .success(SDL_Color(r: r, g: g, b: b, a: a))
        }
    }
    
    @discardableResult
    func setDrawingColor(with colorMod: SDL_Color) -> Result<(), Error> {
        switch SDL_SetRenderDrawColor(_pointer, colorMod.r, colorMod.g, colorMod.b, colorMod.a) {
        case -1:
            return .failure(SDLError.error(Thread.callStackSymbols))
        default:
            return .success(())
        }
    }
    
    @discardableResult
    func copy(from texture: SDL.Texture, from srcrect: SDL_Rect? = nil, to dstrect: SDL_Rect? = nil, rotatedBy angle: Double = 0, aroundCenter point: SDL_Point? = nil, flipped flip: Flip = .none) -> Result<(), Error> {
        let sourceRect: UnsafePointer<SDL_Rect>! = withUnsafePointer(to: srcrect) {
            guard $0.pointee != nil else {
                return nil
            }
            return $0.withMemoryRebound(to: SDL_Rect.self, capacity: 1) { return $0 }
        }
        let destRect: UnsafePointer<SDL_Rect>! = withUnsafePointer(to: dstrect) {
            guard $0.pointee != nil else {
                return nil
            }
            return $0.withMemoryRebound(to: SDL_Rect.self, capacity: 1) { $0 }
        }
        let centerPoint: UnsafePointer<SDL_Point>! = withUnsafePointer(to: point) {
            guard $0.pointee != nil else {
                return nil
            }
            return $0.withMemoryRebound(to: SDL_Point.self, capacity: 1) { $0 }
        }

        switch SDL_RenderCopyEx(_pointer, texture._pointer, sourceRect, destRect, angle, centerPoint, SDL_RendererFlip(rawValue: flip.rawValue)) {
        case -1:
            return .failure(SDLError.error(Thread.callStackSymbols))
        default:
            return .success(())
        }
    }

    /**
     Get information about a rendering context.
     */
    var rendererInfo: RendererInfo {
        var info = SDL_RendererInfo()
        SDL_GetRendererInfo(_pointer, &info)
        return info
    }
    
    @available(OSX 10.11, *)
    var metalLayer: CAMetalLayer? {
        guard let untypedMutablePtr = SDL_RenderGetMetalLayer(_pointer) else {
            return nil
        }
        
        let typedMutablePtr = untypedMutablePtr.assumingMemoryBound(to: CAMetalLayer.self)
        let typedPtr = UnsafeRawPointer(typedMutablePtr)
        
        return Unmanaged
            .fromOpaque(typedPtr)
            .takeUnretainedValue()
    }
    
    /**
     Clear the current rendering target with the drawing color
     
     This function clears the entire rendering target, ignoring the viewport and
     the clip rectangle.
     */
    @discardableResult
    func clear() -> Result<(), Error> {
        switch SDL_RenderClear(_pointer) {
        case -1:
            return .failure(SDLError.error(Thread.callStackSymbols))
        default:
            return .success(())
        }
    }
    
    /**
     Update the screen with rendering performed.
     */
    func present() {
        SDL_RenderPresent(_pointer)
    }
}

extension SDL_RendererInfo: CustomDebugStringConvertible {
    public var label: String {
        return String(cString: name).uppercased()
    }
    
    public var textureFormats: [UInt32] {
        var tmp = texture_formats
        return withUnsafePointer(to: &tmp.0) {
            [UInt32](UnsafeBufferPointer(start: $0, count: Int(num_texture_formats)))
        }
    }
    
    public var textureFormatNames: [String] {
        textureFormats
            .compactMap(SDL_GetPixelFormatName)
            .map(String.init)
    }
    
    public func copyTextureFormats() -> [SDL.PixelFormat] {
        textureFormats
            .compactMap(SDL_AllocFormat)
            .map(SDL.PixelFormat.init)
    }

    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    public func has(flags: SDL.Renderer.RenderFlags...) -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
    
    public var debugDescription: String {
        """
        Driver Name: \(label)
          Hardware Acceleration: \(has(flags: .hardwareAcceleration))
          Software Rendering:    \(has(flags: .softwareRendering))
          Target Texturing:      \(has(flags: .targetTexturing))
          Veritical Sync:        \(has(flags: .verticalSync))
          Pixel Format Count:    \(num_texture_formats)
          Pixel Format Enums:
          \t- \(textureFormatNames.joined(separator: "\n\t- "))
        """
    }
}
