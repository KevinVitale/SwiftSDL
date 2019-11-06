import Foundation
import CSDL2
import SwiftSDL2

struct CharacterSprites {
    static func load(format: SDL_PixelFormatEnum.RawValue, sizedAt size: (x: Float, y: Float) = (x: 32, y: 32), into renderer: SDLRenderer?, resourceURL sourceURL: URL = Bundle.main.resourceURL!, atlasName: String) throws -> [[SDLTexture]] {
        let sourceTexture  = try SDLTexture.load(into: renderer, resourceURL: Bundle.main.resourceURL!, texturesNamed: atlasName).first?.value
        let characterCount = Int((try sourceTexture?.sizeF().y ?? .zero) / size.y)
        
        var characterAnimations = [[SDLTexture]]()
        for index in 0..<characterCount {
            let position   = (x: size.x, y: size.y * Float(index))
            var frameCount = 8
            
            // Frame count depends on sprite -----------------------------------
            switch index {
            case 0: fallthrough
            case 3: frameCount = 4
            default: ()
            }
            
            // Separate the textures, and append -------------------------------
            let textures = try SDLTexture.separateTextures(from: sourceTexture, frameCount: frameCount, format: format, sized: size, locatedAt: position, into: renderer, resourceURL: sourceURL)
            characterAnimations.append(textures)
        }
        
        return characterAnimations
    }
}
