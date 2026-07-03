import Testing
import SwiftSDL

// Task 2 regression tests — these convenience forms once failed to compile
// ("generic parameter 'P' / 'some Window' could not be inferred"); compiling
// is itself part of the assertion.
extension SDLRuntimeTests {
  @Suite struct RendererConvenienceAPI {
    init() throws {
      try #require(SDLTestSupport.videoReady, "dummy video driver failed to initialize")
    }

    /// Window-only form: must compile and attach the renderer to the window.
    @Test func windowOnlyForm() throws {
      let window = try SDL_CreateWindow("SwiftSDL task 2", size: [320, 240], flags: .hidden)
      let renderer = try SDL_CreateRenderer(window: window)
      #expect(SDL_GetRenderWindow(renderer.pointer) == window.pointer)
    }

    /// Properties-only form: must compile. Creation legitimately fails at
    /// runtime without a window or surface target (only the "gpu" driver
    /// allows that) — compiling is the assertion.
    @Test func propertiesOnlyFormCompiles() {
      #expect(throws: SDL_Error.self) {
        try SDL_CreateRenderer(with: (SDL_PROP_RENDERER_CREATE_NAME_STRING, value: "software"))
      }
    }
  }
}
