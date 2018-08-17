import Clibsdl2

@discardableResult
public func InitializeSDL(flags: UInt32...) -> Int32
{
    return SDL_Init(flags.reduce(0) { $0 | $1 })
}

@discardableResult
public func InitializeImage(flags: IMG_InitFlags...) -> Int32
{
    return IMG_Init(flags.reduce(0) { $0 | Int32($1.rawValue) })
}
