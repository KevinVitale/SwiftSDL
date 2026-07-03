import Testing
import SwiftSDL

private struct Boom: Error {}

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
        // Desired behavior: the foreign error surfaces as a thrown Swift
        // error (wrapped in SDL_Error) instead of terminating the process.
      }
    }
  }
}
