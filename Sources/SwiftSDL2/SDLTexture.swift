import Foundation
import CSDL2
import CSDL2_Image

public final class SDLTexture: SDLPointer<SDLTexture>, SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
    
    private func query() throws -> Result<(pixelFormat: UInt32, access: Int32, width: Int32, height: Int32),Error> {
        var pixelFormat  : UInt32 = 0
        var access       : Int32  = 0
        var width        : Int32  = 0
        var height       : Int32  = 0
        return self
            .result(of: SDL_QueryTexture, &pixelFormat, &access, &width, &height)
            .map { _ in ( pixelFormat: pixelFormat,
                               access: access,
                                width: width,
                               height: height )
        }
    }
    
    public func sizeF() throws -> (x: Float, y: Float) {
        try query()
            .map({ (x: Float($0.width), y: Float($0.height)) })
            .get()
    }
    
    func size() throws -> (x: Int32, y: Int32) {
        try query()
            .map({ (x: $0.width, y: $0.height) })
            .get()
    }
    
    public static func load(into renderer: SDLRenderer?, resourceURL sourceURL: URL, texturesNamed names: String...) throws -> [String:SDLTexture] {
        let textures = names
            .compactMap { sourceURL.appendingPathComponent($0) }
            .compactMap { renderer?.pass(to: IMG_LoadTexture, $0.path) }
            .map(SDLTexture.init)
        
        //----------------------------------------------------------------------
        return zip(names, textures).reduce(into: [String:SDLTexture]()) { result, pair in result[pair.0] = pair.1 }
    }
    
    public static func separateTextures(from sourceTexture: SDLTexture?,
                                                frameCount: Int,
                                                    format: SDL_PixelFormatEnum.RawValue,
                                                sized size: (x: Float, y: Float),
                                        locatedAt position: (x: Float, y: Float),
                                             into renderer: SDLRenderer?,
                                     resourceURL sourceURL: URL) throws -> [SDLTexture]
    {
        var textures = [SDLTexture?]()
        for frame in 0..<Int32(frameCount) {
            // Create a target texture -----------------------------------------
            let frameAsTexture = renderer?
                .pass(to: SDL_CreateTexture, format, Int32(SDL_TEXTUREACCESS_TARGET.rawValue), Int32(size.x), Int32(size.y))
                .map(SDLTexture.init)
            
            // Set current render target and clear it --------------------------
            try frameAsTexture?.result(of: SDL_SetTextureBlendMode, .init(SDL_BLENDMODE_BLEND.rawValue)).get()
            try       renderer?.result(of: SDL_SetRenderTarget, frameAsTexture?.pass(to: { $0 })).get()
            try       renderer?.result(of: SDL_SetRenderDrawColor, 255, 255, 255, 0).get()
            try       renderer?.result(of: SDL_SetRenderDrawBlendMode, .init(SDL_BLENDMODE_BLEND.rawValue)).get()
            try       renderer?.result(of: SDL_RenderClear).get()
            
            // Blit to target target texture -----------------------------------
            let sourceRect = SDL_Rect(x: Int32(position.x) * frame, y: Int32(position.y), w: Int32(size.x), h: Int32(size.y))
            try renderer?.copy(from: sourceTexture, within: sourceRect).get()
            try renderer?.result(of: SDL_SetRenderTarget, nil).get()
            
            //------------------------------------------------------------------
            textures.append(frameAsTexture)
            
            try renderer?.result(of: SDL_SetRenderTarget, nil).get()
        }
        
        return textures.compactMap({ $0 })
    }
}
