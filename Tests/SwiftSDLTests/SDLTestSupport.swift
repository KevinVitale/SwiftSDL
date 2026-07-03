import Testing
import SwiftSDL

/// SDL is process-global state: initialize the headless "dummy" video driver
/// exactly once per test process. Suites that touch SDL at runtime must live
/// under `SDLRuntimeTests` (which is `.serialized`) — SDL's video and render
/// APIs are not designed for concurrent callers.
enum SDLTestSupport {
  static let videoReady: Bool = {
    _ = SDL_SetHint(SDL_HINT_VIDEO_DRIVER, "dummy")
    return SDL_InitSubSystem(SDL_INIT_VIDEO)
  }()
}

/// A deterministic, headless render target: a software renderer drawing into
/// a plain RGBA surface whose pixels tests can read back.
struct Canvas {
  let surface: any Surface
  let renderer: any Renderer
}

func makeCanvas(width: Int32 = 64, height: Int32 = 64) throws(SDL_Error) -> Canvas {
  guard let surfacePointer = SDL_CreateSurface(width, height, SDL_PIXELFORMAT_RGBA8888) else {
    throw .error
  }
  let surface: any Surface = SDLObject(surfacePointer, destroy: SDL_DestroySurface)

  guard let rendererPointer = SDL_CreateSoftwareRenderer(surfacePointer) else {
    throw .error
  }
  // The destroy closure captures the surface so it cannot be released
  // before the renderer that draws into it.
  let renderer: any Renderer = SDLObject(rendererPointer, destroy: { pointer in
    SDL_DestroyRenderer(pointer)
    _ = surface
  })

  return Canvas(surface: surface, renderer: renderer)
}

func pixel(at x: Int32, _ y: Int32, of surface: any Surface) throws(SDL_Error) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
  var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 0
  guard SDL_ReadSurfacePixel(surface.pointer, x, y, &r, &g, &b, &a) else {
    throw .error
  }
  return (r, g, b, a)
}
