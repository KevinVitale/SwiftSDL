import Testing
import SwiftSDL

/// The '%' in the description is deliberate: SDL_SetErrorV treats its message
/// as a printf format string, so the wrapper must escape or bypass it.
private struct Boom: Error, CustomStringConvertible {
  var description: String { "Boom(100%)" }
}

/// Task 4 (RED) — `pass(to:)` must surface callback errors as thrown Swift
/// errors, not kill the process via fatalError.
///
/// Runs as an exit test because the current implementation crashes: red = the
/// child process dies (fatalError), green = the child catches a thrown error
/// and exits normally. After the fix, this can become a plain in-process
/// `#expect(throws:)` test if preferred.
@Suite struct PassCallbackTests {
  @Test func foreignCallbackErrorsAreRethrownNotFatal() async {
    await #expect(processExitsWith: .success) {
      let canvas = try makeCanvas()
      do {
        try canvas.renderer.pass(to: { _ in throw Boom() })
        fatalError("pass(to:) swallowed the callback error")
      } catch {
        // Desired behavior: the foreign error surfaces as a thrown SDL_Error
        // (guaranteed by pass(to:)'s typed throws) instead of terminating the
        // process — and the wrapper preserves the original description.
        guard String(describing: error).contains("Boom(100%)") else {
          fatalError("wrapped error lost or mangled the original description: \(error)")
        }
      }
    }
  }
}
