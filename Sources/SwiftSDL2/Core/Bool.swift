import Clibsdl2

extension SDL_bool: ExpressibleByBooleanLiteral
{
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
