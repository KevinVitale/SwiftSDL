import Clibsdl2

enum Error: Swift.Error, CustomStringConvertible
{
    case error
    
    var description: String {
        return String(cString: SDL_GetError())
    }
}
