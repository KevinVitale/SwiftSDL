import CSDL2

public extension Bool {
    var SDLBool: SDL_bool {
        return self == true ? SDL_TRUE : SDL_FALSE
    }
}

public extension SDL_bool {
    var bool: Bool {
        switch self {
        case SDL_TRUE: return true
        default: return false
        }
    }
}
