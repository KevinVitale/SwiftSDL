import Clibsdl2

public enum Error: Swift.Error, CustomStringConvertible
{
    case error(_ callStackSymbols: [String]?)
    
    public var callStackSymbols: [String] {
        switch self {
        case .error(let callStackSymbols?):
            return callStackSymbols
        default:
            return []
        }
    }
    
    public static func clear() {
        SDL_ClearError()
    }
    
    public var description: String {
        let errorDesc = String(cString: SDL_GetError())
        let callStack = callStackSymbols.joined(separator: "\n")
        return errorDesc + "\n" + callStack
    }
}
