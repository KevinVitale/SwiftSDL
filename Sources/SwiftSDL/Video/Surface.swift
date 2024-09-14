public final class SurfacePtr: SDLPointer {
  public static func destroy(_ pointer: UnsafeMutablePointer<SDL_Surface>) {
    SDL_DestroySurface(pointer)
  }
}

@MainActor
public protocol Surface: SDLObjectProtocol where Pointer == SurfacePtr { }

extension SDLObject<SurfacePtr>: Surface { }

/*
extension Result: Surface
where Success: SDLObjectProtocol,
      Success.Pointer == SurfacePtr,
      Failure == SDL_Error
{ }
*/

extension Surface {
  @discardableResult
  public func clear(color: SDL_Color? = nil) throws(SDL_Error) -> Self {
    let bgColor = color ?? .black
    
    let red = Float(bgColor.r) / Float(UInt8.max)
    let green = Float(bgColor.g) / Float(UInt8.max)
    let blue = Float(bgColor.b) / Float(UInt8.max)
    let alpha = Float(bgColor.a) / Float(UInt8.max)
    
    return try set(SDL_ClearSurface, red, green, blue, alpha)
  }
}
