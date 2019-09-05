import Clibsdl2

extension SDL_RendererInfo
{
    public var label: String {
        return String(cString: name)
    }
    
    /**
     - parameter flags: A list of flags to be checked.
     - returns: Evaluates if the receiver contains `flags` in its own list of flags.
     */
    func has(flags: SDL_RendererFlags...) -> Bool{
        let mask = flags.reduce(0) { $0 | $1.rawValue }
        return (self.flags & mask) != 0
    }
}

func Drivers() -> [SDL_RendererInfo]
{
    return (0..<Renderer.driverCount).compactMap { Renderer.driverInfo($0) }
}
