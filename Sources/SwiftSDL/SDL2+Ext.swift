import Clibsdl2

extension SDL_bool: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        switch value {
        case true: self = SDL_TRUE
        case false: self = SDL_FALSE
        }
    }
    
    var boolValue: Bool {
        return self == SDL_TRUE
    }
}

extension SDL_Color {
    static func random(alpha a: UInt8 = 0xFF) -> SDL_Color {
        let r = UInt8(arc4random_uniform(256))
        let g = UInt8(arc4random_uniform(256))
        let b = UInt8(arc4random_uniform(256))
        return SDL_Color(r: r, g: g, b: b, a: a)
    }
}
