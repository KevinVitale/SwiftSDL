import Foundation.NSThread
import CSDL2
import QuartzCore.CAMetalLayer

public typealias Renderer = SDLPointer<SDLRenderer>

public extension UInt32 {
    static func renderFlags(_ flags: Renderer.RenderFlag...) -> UInt32 {
        flags.reduce(0) { $0 | $1.rawValue }
    }
}

public struct SDLRenderer: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyRenderer(pointer)
    }
}

public extension SDLPointer where T == SDLRenderer {
    struct RenderFlag: OptionSet {
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlags.RawValue
        
        public static let hardwareAcceleration = RenderFlag(rawValue: SDL_RENDERER_ACCELERATED.rawValue)
        public static let softwareRendering    = RenderFlag(rawValue: SDL_RENDERER_SOFTWARE.rawValue)
        public static let targetTexturing      = RenderFlag(rawValue: SDL_RENDERER_TARGETTEXTURE.rawValue)
        public static let verticalSync         = RenderFlag(rawValue: SDL_RENDERER_PRESENTVSYNC.rawValue)
    }
    
    struct RenderFlip: OptionSet {
        public init(rawValue: SDL_RendererFlip.RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: SDL_RendererFlip.RawValue
        
        public static let none       = RenderFlip(rawValue: SDL_FLIP_NONE.rawValue)
        public static let vertical   = RenderFlip(rawValue: SDL_FLIP_VERTICAL.rawValue)
        public static let horizontal = RenderFlip(rawValue: SDL_FLIP_HORIZONTAL.rawValue)
    }
    
    static func renderers(at indexes: Int32...) -> [SDL_RendererInfo] {
        return Self.renderers(at: indexes)
    }
    
    /**
     Returns info for a the driver at a specific index.
     
     - parameter index: The index of the driver being queried.
     */
    static func renderers(at indexes: [Int32] = Array(0..<Int32(SDL_GetNumRenderDrivers()))) -> [SDL_RendererInfo] {
        indexes.compactMap {
            var info = SDL_RendererInfo()
            guard SDL_GetRenderDriverInfo($0, &info) >= 0 else {
                return nil
            }
            return info
        }
    }
    
    @available(OSX 10.11, *)
    weak var metalLayer: CAMetalLayer? {
        return unsafeBitCast(self.pass(to: SDL_RenderGetMetalLayer), to: CAMetalLayer?.self)
    }
    
    @discardableResult
    func copy(texture: Texture?, from srcrect: SDL_Rect? = nil, into dstrect: SDL_Rect? = nil, rotatedBy angle: Double = 0, aroundCenter point: SDL_Point? = nil, flipped flip: RenderFlip = .none) -> Result<(), Error> {
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
        
        return self.result(of: { renderer in
            texture?.pass(to: {
                SDL_RenderCopyEx(renderer, $0, sourceRect, destRect, angle, centerPoint, SDL_RendererFlip(rawValue: flip.rawValue))
            }) ?? 0
        })
    }
}
