import Testing
import SwiftSDL

/// SDL_Error.wrap is the shared foreign-error adapter used by
/// Renderer.pass(to:) and CommandBuffer.render(to:) — both previously
/// crashed the process on non-SDL errors (fatalError and 'as!' force-cast
/// respectively). SDL's error functions work pre-init, so no fixture needed.
@Suite struct ErrorWrapTests {
  struct Boom: Error, CustomStringConvertible {
    var description: String { "Boom(50%)" }
  }

  /// Foreign errors survive wrapping with their description intact —
  /// including '%' characters, which must not reach SDL_SetErrorV as
  /// format directives.
  @Test func wrapPreservesForeignDescription() {
    let wrapped = SDL_Error.wrap(Boom())
    #expect(String(describing: wrapped).contains("Boom(50%)"))
  }

  /// SDL errors pass through unchanged rather than being double-wrapped.
  @Test func wrapPassesThroughSDLError() {
    let original = SDL_Error.custom("already sdl")
    let wrapped = SDL_Error.wrap(original)
    #expect(String(describing: wrapped) == "already sdl")
  }
}
