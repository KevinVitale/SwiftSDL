import Foundation.NSThread
import CSDL2

public struct SDLSurface: SDLType {
    public static func destroy(pointer: UnsafeMutablePointer<SDL_Surface>) {
        SDL_FreeSurface(pointer)
    }
}

public typealias Surface = SDLPointer<SDLSurface>

public extension SDLPointer where T == SDLSurface {
    convenience init?(width: Int32, height: Int32, depth: Int32, redMask: UInt32 = .min, greenMask: UInt32 = .min, blueMask: UInt32 = .min, alphaMask: UInt32 = .min) {
        return nil
    }
    
    convenience init?(width: Int32, height: Int32, format: UInt32) {
        return nil
    }
    
    convenience init?(pixels: UnsafeMutableRawPointer!, width: Int32, height: Int32, depth: Int32, pitch: Int32, redMask: UInt32, greenMask: UInt32, blueMask: UInt32, alphaMask: UInt32) {
        return nil
    }
    
    convenience init?(pixels: UnsafeMutableRawPointer!, width: Int32, height: Int32, pitch: Int32, format: UInt32) {
        return nil
    }

    static func surface(forWindow window: SDL.Window) -> Result<Surface, Error> {
        guard let surface = SDL_GetWindowSurface(window._pointer) else {
            return .failure(SDLError.error(Thread.callStackSymbols))
        }
        return .success(Self(pointer: surface))
    }

    var clippingRect: SDL_Rect {
        return _pointer.pointee.clip_rect
    }
    
    var format: UnsafeMutablePointer<SDL_PixelFormat>! {
        return _pointer.pointee.format
    }
    
    var height: Int32 {
        return _pointer.pointee.h
    }
    
    var width: Int32 {
        return _pointer.pointee.w
    }

    var pitch: Int32 {
        return _pointer.pointee.pitch
    }
    
    var userData: UnsafeMutableRawPointer! {
        get { _pointer.pointee.userdata }
        set { _pointer.pointee.userdata = newValue }
    }

    func lock() -> Bool {
        SDL_LockSurface(_pointer) == -1 ? false : true
    }
    
    func unlock() {
        SDL_UnlockSurface(_pointer)
    }
    
    func fill(rect fillRect: SDL_Rect? = nil, color: SDL_Color) throws {
        let rect: UnsafePointer<SDL_Rect>! = withUnsafePointer(to: fillRect) {
            guard $0.pointee != nil else {
                return nil
            }
            return $0.withMemoryRebound(to: SDL_Rect.self, capacity: 1) { return $0 }
        }

        guard SDL_FillRect(_pointer, rect, color.mapRGB(format: self.format)) == 0 else {
            throw SDLError.error(Thread.callStackSymbols)
        }
    }
    
    func fill(rects fillRects: [SDL_Rect], color: SDL_Color) throws {
        var rects = fillRects
        guard SDL_FillRects(_pointer, &rects, Int32(fillRects.count), color.mapRGB(format: self.format)) == 0 else {
            throw SDLError.error(Thread.callStackSymbols)
        }
    }

    func fill(rects fillRects: SDL_Rect..., color: SDL_Color) throws {
        try self.fill(rects: fillRects, color: color)
    }
}
