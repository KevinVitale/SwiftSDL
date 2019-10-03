import Foundation.NSThread
import CSDL2
import QuartzCore.CAMetalLayer

public struct SDLRenderer: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
}


public extension SDL { typealias Renderer = SDLPointer<SDLRenderer> }

public extension SDL.Renderer {
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

    convenience init(window: SDL.Window, driver index: Int = -1, flags renderFlags: RenderFlags...) throws {
        let flags: UInt32 = renderFlags.reduce(0) { $0 | $1.rawValue }
        guard let pointer = SDL_CreateRenderer(window._pointer, Int32(index), flags) else {
            throw SDLError.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    /**
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
        RendererInfo(for: self)
    }
    
    var name: String {
        rendererInfo.label
    }
    
    @available(OSX 10.11, *)
    var metalLayer: CAMetalLayer? {
        return unsafeBitCast(SDL_RenderGetMetalLayer(_pointer), to: CAMetalLayer?.self)
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
    
    @discardableResult
    func flush() -> Result<(), Error> {
        switch SDL_RenderFlush(_pointer) {
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

public extension SDLPointer where T == SDLRenderer {
    typealias RendererInfo = SDL_RendererInfo
    
    static func renderers(at indexes: Int32...) -> [RendererInfo] {
        return Self.renderers(at: indexes)
    }
    
    /**
     Returns info for a the driver at a specific index.
     
     - parameter index: The index of the driver being queried.
     */
    static func renderers(at indexes: [Int32] = Array(0..<Int32(SDL_GetNumRenderDrivers()))) -> [RendererInfo] {
        indexes.compactMap {
            var info = SDL_RendererInfo()
            guard SDL_GetRenderDriverInfo(Int32($0), &info) >= 0 else {
                return nil
            }
            return info
        }
    }

    static func copyTextureFormats(for rendererInfo: SDL.Renderer.RendererInfo) -> [SDL.PixelFormat] {
        return rendererInfo.copyTextureFormats()
    }
}

fileprivate extension SDL.Renderer.RendererInfo {
    init(for renderer: SDL.Renderer) {
        var info = SDL_RendererInfo()
        SDL_GetRendererInfo(renderer._pointer, &info)
        self = info
    }
    
    var label: String {
        return String(cString: name).uppercased()
    }
    
    var textureFormats: [UInt32] {
        var tmp = texture_formats
        return withUnsafePointer(to: &tmp.0) {
            [UInt32](UnsafeBufferPointer(start: $0, count: Int(num_texture_formats)))
        }
    }
    
    var textureFormatNames: [String] {
        textureFormats
            .compactMap(SDL_GetPixelFormatName)
            .map(String.init)
    }
    
    func copyTextureFormats() -> [SDL.PixelFormat] {
        textureFormats
            .compactMap(SDL_AllocFormat)
            .map(SDL.PixelFormat.init)
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL.Renderer.RenderFlags...) -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
}

extension SDL_RendererInfo: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Driver Name: \(label)
          : Hardware Acceleration: \(has(flags: .hardwareAcceleration))
          : Software Rendering:    \(has(flags: .softwareRendering))
          : Target Texturing:      \(has(flags: .targetTexturing))
          : Veritical Sync:        \(has(flags: .verticalSync))
          : Pixel Format Count:    \(num_texture_formats)
          : Pixel Format Enums:
          \t- \(textureFormatNames.joined(separator: "\n\t- "))
        """
    }
}
