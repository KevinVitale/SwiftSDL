import CSDL2
#if canImport(QuartzCore)
import QuartzCore.CAMetalLayer
#endif

public final class SDLRenderer: SDLPointer<SDLRenderer>, SDLType {
    public struct Flag: OptionSet {
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlags.RawValue
        
        public static let hardwareAcceleration = Flag(rawValue: SDL_RENDERER_ACCELERATED.rawValue)
        public static let softwareRendering    = Flag(rawValue: SDL_RENDERER_SOFTWARE.rawValue)
        public static let targetTexturing      = Flag(rawValue: SDL_RENDERER_TARGETTEXTURE.rawValue)
        public static let verticalSync         = Flag(rawValue: SDL_RENDERER_PRESENTVSYNC.rawValue)
    }
    
    public struct Flip: OptionSet {
        public init(rawValue: SDL_RendererFlip.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlip.RawValue
        
        public static let none       = Flip(rawValue: SDL_FLIP_NONE.rawValue)
        public static let vertical   = Flip(rawValue: SDL_FLIP_VERTICAL.rawValue)
        public static let horizontal = Flip(rawValue: SDL_FLIP_HORIZONTAL.rawValue)
    }
    
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
}

public extension SDLRenderer {
    static func renderers(at indexes: Int32...) -> [SDL_RendererInfo] {
        return Self.availableRenderers(at: indexes)
    }
    
    /**
     Returns info for a the driver at a specific index.
     
     - parameter index: The index of the driver being queried.
     */
    static func availableRenderers(at indexes: [Int32] = Array(0..<Int32(SDL_GetNumRenderDrivers()))) -> [SDL_RendererInfo] {
        indexes.compactMap {
            var info = SDL_RendererInfo()
            guard SDL_GetRenderDriverInfo($0, &info) >= 0 else {
                return nil
            }
            return info
        }
    }
    
    func info() throws -> SDL_RendererInfo {
        var info = SDL_RendererInfo()
        try self.result(of: SDL_GetRendererInfo, &info).get()
        return info
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func supports(_ flags: Flag...) throws -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (try self.info().flags & mask) != 0
    }
    
    #if canImport(QuartzCore)
    @available(OSX 10.11, *)
    weak var metalLayer: CAMetalLayer? {
        return unsafeBitCast(self.pass(to: SDL_RenderGetMetalLayer), to: CAMetalLayer?.self)
    }
    #endif
    
    @discardableResult
    func copy(from texture: SDLTexture?, within srcrect: SDL_Rect? = nil, into dstrect: SDL_Rect? = nil, rotatedBy angle: Double = 0, aroundCenter point: SDL_Point? = nil, flipped flip: Flip = .none) -> Result<(), Error> {
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
        
        return Result {
            try self.result(of: SDL_RenderCopyEx, texture?.pass(to: { $0 }), sourceRect, destRect, angle, centerPoint, SDL_RendererFlip(rawValue: flip.rawValue)).get()
        }
    }
}

public extension UInt32 {
    static func renderFlags(_ flags: SDLRenderer.Flag...) -> UInt32 {
        flags.reduce(0) { $0 | $1.rawValue }
    }
}

