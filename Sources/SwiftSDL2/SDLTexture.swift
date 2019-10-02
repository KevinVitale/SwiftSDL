import Foundation.NSThread
import Clibsdl2

public struct SDLTexture: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
}

public typealias Texture = SDLPointer<SDLTexture>

public extension SDLPointer where T == SDLTexture {
    /**
     Create a texture for a rendering context.
     
     - parameter renderer: The renderer.
     - parameter format: The format of the texture.
     - parameter access: One of the enumerated values in `SDL_TextureAccess`.
     - parameter width: The width of the texture in pixels.
     - parameter height: The height of the texture in pixels.
     
     - returns: The created texture is returned, or NULL if no rendering context
     was active, the format was unsupported, or the width or height
     were out of range.
     
     - note: The contents of the texture are not defined at creation.
     */
    init(renderer: SDLPointer<SDLRenderer>, format: Int, access: SDL_TextureAccess, width: Int, height: Int) throws {
        guard let pointer = SDL_CreateTexture(renderer._pointer, UInt32(format), Int32(access.rawValue), Int32(width), Int32(height)) else {
            throw Error.error(Thread.callStackSymbols)
        }
        self.init(pointer: pointer)
    }
    
    init?(renderer: SDLPointer<SDLRenderer>, pathURL url: URL) throws {
        let surface = url.path.withCString { IMG_Load($0) }
        
        defer {
            if surface != nil {
                SDL_FreeSurface(surface)
            }
        }
        
        guard let pointer = SDL_CreateTextureFromSurface(renderer._pointer, surface) else {
            throw Error.error(Thread.callStackSymbols)
        }
        
        self.init(pointer: pointer)
    }
    
    init?(renderer: SDLPointer<SDLRenderer>, surface: Surface!) {
        guard let pointer = SDL_CreateTextureFromSurface(renderer._pointer, surface) else {
            return nil
        }
        self.init(pointer: pointer)
    }
    
    private func query() -> (format: UInt32, formatName: String, access: SDL_TextureAccess, width: Int, height: Int) {
        var format: UInt32 = UInt32(SDL_PIXELTYPE_UNKNOWN)
        var access: Int32  = 0
        var width:  Int32  = 0
        var height: Int32  = 0
        SDL_QueryTexture(_pointer ,&format ,&access ,&width ,&height)
        let formatName: String = String(cString: SDL_GetPixelFormatName(format))
        return (
            format: format
            , formatName: formatName
            , access: SDL_TextureAccess(rawValue: UInt32(access))
            , width: Int(width)
            , height: Int(height)
        )
    }
    
    var attributes: (format: UInt32, formatName: String, access: SDL_TextureAccess, width: Int, height: Int) {
        return query()
    }
    
    var format: UInt32 {
        return attributes.format
    }
    
    var formatName: String {
        return attributes.formatName
    }
    
    var access: SDL_TextureAccess {
        return attributes.access
    }
    
    var width: Int {
        return attributes.width
    }
    
    var height: Int {
        return attributes.height
    }
    
    func getColorMod() -> Result<SDL_Color, Error> {
        var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0
        switch SDL_GetTextureColorMod(_pointer, &r, &g, &b) {
        case -1:
            return .failure(Error.error(Thread.callStackSymbols))
        default:
            return .success(SDL_Color(r: r, g: g, b: b, a: .max))
        }
    }
    
    @discardableResult
    func setColorMod(with colorMod: SDL_Color) -> Result<(), Error> {
        switch SDL_SetTextureColorMod(_pointer, colorMod.r, colorMod.g, colorMod.b) {
        case -1:
            return .failure(Error.error(Thread.callStackSymbols))
        default:
            return .success(())
        }
    }
}
