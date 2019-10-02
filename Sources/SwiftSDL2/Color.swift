import CSDL2

public extension SDL_Color
{
    @inline(__always)
    static func random(alpha a: UInt8 = 0xFF) -> SDL_Color {
        let r = UInt8(arc4random_uniform(256))
        let g = UInt8(arc4random_uniform(256))
        let b = UInt8(arc4random_uniform(256))
        return SDL_Color(r: r, g: g, b: b, a: a)
    }
    
    func mapRGB(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGB(format, self.r, self.g, self.b)
    }
    
    func mapRGBA(format: UnsafeMutablePointer<SDL_PixelFormat>!) -> UInt32 {
        return SDL_MapRGBA(format, self.r, self.g, self.b, self.a)
    }
}
