import Testing
import SwiftSDL

// Task 2 — these convenience forms currently DO NOT COMPILE:
//
//   SDL_CreateRenderer(window: w)                 // error: generic parameter 'P' could not be inferred
//   SDL_CreateRenderer(with: ("name", value: v))  // error: generic parameter 'some Window' could not be inferred
//
// Red phase: run `swift test -Xswiftc -DSWIFTSDL_TASK2_FIXED` and watch the
// test target fail to build with exactly those errors. Green phase: the fix
// makes this file compile and the tests pass — then delete the #if gate so
// these run unconditionally.
#if SWIFTSDL_TASK2_FIXED
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
    /// runtime without a window or surface target — compiling is the assertion.
    @Test func propertiesOnlyFormCompiles() {
      #expect(throws: SDL_Error.self) {
        try SDL_CreateRenderer(with: (SDL_PROP_RENDERER_CREATE_NAME_STRING, value: "software"))
      }
    }
  }
}
#endif
