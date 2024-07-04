import CSDL2
import Foundation

public extension SDL_RendererInfo {
    var textureFormats: [UInt32] {
        var tmp = texture_formats
        return withUnsafePointer(to: &tmp.0) {
            [UInt32](UnsafeBufferPointer(start: $0, count: Int(num_texture_formats)))
        }
    }
    
    var textureFormatNames: [String] {
        textureFormats.map(SDLPixelFormat.name)
    }
    
    func copyTextureFormats() -> [SDLPixelFormat] {
        textureFormats
            .compactMap(SDL_AllocFormat)
            .map(SDLPixelFormat.init)
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func supports(flags: SDLRenderer.Flag...) -> Bool {
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
}

extension SDL_RendererInfo: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Driver Name: \(String(cString: name).uppercased())
        : Hardware Acceleration: \(supports(flags: .hardwareAcceleration))
        : Software Rendering:    \(supports(flags: .softwareRendering))
        : Target Texturing:      \(supports(flags: .targetTexturing))
        : Veritical Sync:        \(supports(flags: .verticalSync))
        : Max Textue Width:      \(max_texture_width)
        : Max Textue Height:     \(max_texture_height)
        : Pixel Format Enums:    (\(num_texture_formats) count)
        \t- \(textureFormatNames.joined(separator: "\n\t- "))
        """
    }
}


