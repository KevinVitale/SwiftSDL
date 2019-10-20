import Foundation
import CSDL2
import CSDL2_Image

public typealias Texture = SDLPointer<SDLTexture>

public struct SDLTexture: SDLType {
    public static func destroy(pointer: OpaquePointer) {
        SDL_DestroyTexture(pointer)
    }
}

public extension SDLPointer where T == SDLTexture {
    private func query() throws -> Result<(pixelFormat: UInt32, access: Int32, width: Int32, height: Int32),Error> {
        var pixelFormat  : UInt32 = 0
        var access       : Int32  = 0
        var width        : Int32  = 0
        var height       : Int32  = 0
        return self
            .result(of: SDL_QueryTexture, &pixelFormat, &access, &width, &height)
            .map { _ in
                (pixelFormat: pixelFormat, access: access, width: width, height: height)
        }
    }
    
    func sizeF() throws -> (x: Float, y: Float) {
        try query()
            .map({ (x: Float($0.width), y: Float($0.height)) })
            .get()
    }
    
    func size() throws -> (x: Int32, y: Int32) {
        try query()
            .map({ (x: $0.width, y: $0.height) })
            .get()
    }
    
    static func load(into renderer: Renderer?, resourceURL sourceURL: URL, texturesNamed names: String...) throws -> [String:Texture] {
        let textures = names
            .compactMap { sourceURL.appendingPathComponent($0) }
            .compactMap { renderer?.pass(to: IMG_LoadTexture, $0.path) }
            .map(Texture.init)
        
        //----------------------------------------------------------------------
        return zip(names, textures).reduce(into: [String:Texture]()) { result, pair in result[pair.0] = pair.1 }
    }
}
