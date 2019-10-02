import CSDL2

extension Bool {
    var SDLBool: SDL_bool {
        return self == true ? SDL_TRUE : SDL_FALSE
    }
}
