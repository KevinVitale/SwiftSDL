import Clibsdl2

enum SDL2Error: Swift.Error, CustomStringConvertible
{
    case error
    
    static func clear() {
        SDL_ClearError()
    }
    
    var description: String {
        return String(cString: SDL_GetError())
    }
}
