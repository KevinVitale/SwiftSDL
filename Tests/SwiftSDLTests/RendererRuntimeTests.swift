import Testing
import SwiftSDL

/// Umbrella for every test that touches SDL at runtime. `.serialized` applies
/// recursively to the nested suites — SDL is process-global state.
@Suite(.serialized) struct SDLRuntimeTests {

  @Suite struct RendererCreation {
    init() throws {
      try #require(SDLTestSupport.videoReady, "dummy video driver failed to initialize")
    }

    /// Task 1 (RED) — the window create-property must carry the SDL_Window
    /// pointer itself, not the address of a Swift local holding it.
    ///
    /// Runs as an exit test because the current implementation SEGFAULTS:
    /// SDL only magic-checks the bogus pointer in helper calls (which fail
    /// harmlessly), then dereferences it inside the render-driver loop.
    /// Red = child dies with SIGSEGV; green = renderer attaches to the window.
    @Test func rendererAttachesToProvidedWindow() async {
      await #expect(processExitsWith: .success) {
        guard SDLTestSupport.videoReady else {
          fatalError("dummy video driver failed to initialize")
        }
        let window = try SDL_CreateWindow("SwiftSDL task 1", size: [320, 240], flags: .hidden)
        // Empty-but-typed property list: currently the only compilable form (see task 2).
        let renderer = try SDL_CreateRenderer(with: [(String, value: Bool)](), window: window)
        #expect(SDL_GetRenderWindow(renderer.pointer) == window.pointer)
      }
    }

    /// Task 6 (RED) — properties passed to `Window.createRenderer(with:)`
    /// must reach SDL. Verified via vsync, which SDL applies from the create
    /// properties (SDL_render.c:1247) and simulates on the software renderer.
    @Test func createRendererForwardsProperties() throws {
      let window = try SDL_CreateWindow("SwiftSDL task 6", size: [320, 240], flags: .hidden)
      let renderer = try window.createRenderer(
        with: (SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER, value: Sint64(1))
      )
      #expect(try renderer.vsync.get() == 1)
    }
  }

  @Suite struct Surfaces {
    /// GREEN pin — pixel-verified surface fill; guards the pointer-scoping
    /// refactor of Surface.fill(rects:) and pins empty-list no-op behavior.
    @Test func fillRectsDrawsPixels() throws {
      guard let surfacePointer = SDL_CreateSurface(16, 16, SDL_PIXELFORMAT_RGBA8888) else {
        throw SDL_Error.error
      }
      let surface: any Surface = SDLObject(surfacePointer, destroy: SDL_DestroySurface)
      try surface.clear(color: .black)
      try surface.fill(rects: SDL_Rect(x: 2, y: 2, w: 4, h: 4), color: .red)
      #expect(try pixel(at: 3, 3, of: surface) == (r: 255, g: 0, b: 0, a: 255))
      #expect(try pixel(at: 10, 10, of: surface) == (r: 0, g: 0, b: 0, a: 255))
      #expect(throws: Never.self) { try surface.fill(rects: [SDL_Rect](), color: .red) }
    }
  }

  @Suite struct VirtualJoysticks {
    init() throws {
      try #require(SDLTestSupport.videoReady, "dummy video driver failed to initialize")
      try #require(SDL_InitSubSystem(SDL_INIT_JOYSTICK), "joystick subsystem failed to initialize")
    }

    /// The attached device's name must round-trip through SDL — pins the
    /// desc's name/touchpads/sensors pointers being valid at attach time
    /// (the name was previously a dead String-to-pointer temporary).
    @Test func virtualJoystickNameRoundTrips() throws {
      let id = try SDL_AttachVirtualJoystick(
        type: .gamepad,
        name: "SwiftSDL Test Pad",
        touchpads: [SDL_VirtualJoystickTouchpadDesc(nfingers: 2, padding: (0, 0, 0))],
        sensors: [SDL_VirtualJoystickSensorDesc(type: SDL_SENSOR_ACCEL, rate: 0)]
      )
      defer { _ = SDL_DetachVirtualJoystick(id) }

      let namePointer = try #require(SDL_GetJoystickNameForID(id))
      #expect(String(cString: namePointer) == "SwiftSDL Test Pad")
    }
  }

  @Suite struct Drawing {
    init() throws {
      try #require(SDLTestSupport.videoReady, "dummy video driver failed to initialize")
    }

    /// Task 3 (contract pin) — empty draw lists must be no-ops.
    ///
    /// Green today only by two implementation accidents: Swift's empty arrays
    /// share singleton storage with a non-nil baseAddress, and this SDL
    /// build's CHECK_PARAM flavor tolerates it (SDL_internal.h:295-301 —
    /// other flavors assert-crash or error on NULL). Neither is guaranteed;
    /// task 3's fix must keep this green by construction (SDL call inside
    /// withUnsafeBufferPointer, or an explicit early return on empty).
    @Test func emptyDrawListsAreNoOps() throws {
      let canvas = try makeCanvas()
      let renderer = canvas.renderer
      #expect(throws: Never.self) { try renderer.points([SDL_FPoint](), color: .red) }
      #expect(throws: Never.self) { try renderer.lines([SDL_FPoint](), color: .red) }
      #expect(throws: Never.self) { try renderer.fill(rects: [SDL_FRect](), color: .red) }
    }

    /// GREEN pin — pixel-verified fill; guards task 3's fix (moving the SDL
    /// call inside `withUnsafeBufferPointer` must not break drawing).
    @Test func fillRectsDrawsPixels() throws {
      let canvas = try makeCanvas()
      try canvas.renderer
        .clear(color: .black)
        .fill(rects: SDL_FRect(x: 8, y: 8, w: 16, h: 16), color: .red)
        .present()
      #expect(try pixel(at: 10, 10, of: canvas.surface) == (r: 255, g: 0, b: 0, a: 255))
      #expect(try pixel(at: 40, 40, of: canvas.surface) == (r: 0, g: 0, b: 0, a: 255))
    }

    /// GREEN pin — pixel-verified lines (added with task 3's refactor;
    /// `lines` previously had no pixel coverage).
    @Test func linesDrawPixels() throws {
      let canvas = try makeCanvas()
      try canvas.renderer
        .clear(color: .black)
        .lines([SDL_FPoint(x: 2, y: 3), SDL_FPoint(x: 6, y: 3)], color: .white)
        .present()
      #expect(try pixel(at: 2, 3, of: canvas.surface) == (r: 255, g: 255, b: 255, a: 255))
      #expect(try pixel(at: 4, 3, of: canvas.surface) == (r: 255, g: 255, b: 255, a: 255))
      #expect(try pixel(at: 4, 4, of: canvas.surface) == (r: 0, g: 0, b: 0, a: 255))
    }

    /// GREEN pin — pixel-verified points.
    @Test func pointsDrawPixels() throws {
      let canvas = try makeCanvas()
      try canvas.renderer
        .clear(color: .black)
        .points([SDL_FPoint(x: 5, y: 5)], color: .green)
        .present()
      #expect(try pixel(at: 5, 5, of: canvas.surface) == (r: 0, g: 255, b: 0, a: 255))
    }

    /// GREEN pin — draw helpers restore the previous draw color on success
    /// (regression guard for the restore logic touched by tasks 3 and 5).
    @Test func drawHelpersRestoreDrawColor() throws {
      let canvas = try makeCanvas()
      try canvas.renderer.set(color: .blue)
      try canvas.renderer.fill(rects: SDL_FRect(x: 0, y: 0, w: 4, h: 4), color: .yellow)
      let restored = try canvas.renderer.color.get()
      #expect((restored.r, restored.g, restored.b, restored.a) == (0, 0, 255, 255))
    }

    /// Task 5 (GREEN pin, happy path) — debug text restores draw color and
    /// scale on success. The error path is guaranteed structurally: restore
    /// happens in a `defer` in debug(text:) and the draw helpers, so it runs
    /// on every exit path (no deterministic failure lever exists to test it
    /// black-box on a valid software renderer).
    @Test func debugTextRestoresColorAndScale() throws {
      let canvas = try makeCanvas()
      try canvas.renderer.set(color: .blue)
      try canvas.renderer.debug(text: "Hi", position: [2, 2], color: .red, scale: [2, 2])
      let color = try canvas.renderer.color.get()
      let scale = try canvas.renderer.scale.get()
      #expect((color.r, color.g, color.b, color.a) == (0, 0, 255, 255))
      #expect(scale == [1, 1])
    }
  }
}
