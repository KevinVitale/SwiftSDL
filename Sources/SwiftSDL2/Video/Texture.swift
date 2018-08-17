import Clibsdl2

class Texture: WrappedPointer
{
    /**
     Destroy the specified texture.
     */
    override func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
    
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
    convenience init(renderer: Renderer, format: Int, access: SDL_TextureAccess, width: Int, height: Int) throws {
        guard let pointer = SDL_CreateTexture(renderer.pointer, UInt32(format), Int32(access.rawValue), Int32(width), Int32(height)) else {
            throw Error.error
        }
        self.init(pointer: pointer)
    }
    
    /**
     Create a texture from an file located at `path`.
     
     - parameter renderer: The renderer.
     - parameter path: The path to the image data used to fill the texture.
     
     - returns: The created texture is returned, or `nil` on error.
     */
    convenience init?(renderer: Renderer, file path: String) {
        let surface = path.withCString { IMG_Load($0) }
        defer { SDL_FreeSurface(surface) }
        
        self.init(pointer: SDL_CreateTextureFromSurface(renderer.pointer, surface))
    }
    
    private func query() -> (format: UInt32, formatName: String, access: SDL_TextureAccess, width: Int, height: Int) {
        var format: UInt32 = UInt32(SDL_PIXELTYPE_UNKNOWN)
        var access: Int32  = 0
        var width:  Int32  = 0
        var height: Int32  = 0
        SDL_QueryTexture(pointer ,&format ,&access ,&width ,&height)
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
}
