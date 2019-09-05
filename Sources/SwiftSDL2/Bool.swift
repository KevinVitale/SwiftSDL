import Clibsdl2

extension Bool {
    var toSDL: SDL_bool {
        return self == true ? SDL_TRUE : SDL_FALSE
    }
}
