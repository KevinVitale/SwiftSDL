import Testing
import SwiftSDL

/// GPU create-info convenience initializers must assign every parameter they
/// accept to the underlying C struct. Pure struct assertions — no GPU needed,
/// safe to run in parallel.
@Suite struct GPUStructTests {
  /// clearDepth/clearStencil must reach the C struct. When dropped, depth
  /// clears to 0.0 instead of the requested value — with the default LESS
  /// compare, every fragment fails the depth test ("invisible 3D scene").
  @Test func depthStencilTargetInfoAssignsClearValues() {
    let info = SDL_GPUDepthStencilTargetInfo(texture: nil, clearDepth: 0.75, clearStencil: 3)
    #expect(info.clear_depth == 0.75)
    #expect(info.clear_stencil == 3)
    #expect(info.load_op == SDL_GPU_LOADOP_CLEAR)
  }

  /// writeMask must reach the C struct. When dropped, stencil writes are
  /// fully masked off (the DepthSampler bench passes 0xFF and gets 0).
  @Test func depthStencilStateAssignsWriteMask() {
    let state = SDL_GPUDepthStencilState(
      enableDepthTest: true,
      enableDepthWrite: true,
      enableStencilTest: true,
      writeMask: 0xFF
    )
    #expect(state.write_mask == 0xFF)
    #expect(state.compare_op == SDL_GPU_COMPAREOP_LESS)
    #expect(state.enable_depth_test)
    #expect(state.enable_depth_write)
    #expect(state.enable_stencil_test)
  }

  /// GREEN pin — the color-target-info init assigns its fields (clear color,
  /// ops, texture).
  @Test func colorTargetInfoAssignsFields() {
    let raw = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
    defer { raw.deallocate() }
    let dummyTexture = OpaquePointer(raw)

    let info = SDL_GPUColorTargetInfo(texture: dummyTexture, clearColor: 0.1, g: 0.2, b: 0.3)
    #expect(info.texture == dummyTexture)
    #expect(info.clear_color.r == 0.1 && info.clear_color.g == 0.2 && info.clear_color.b == 0.3 && info.clear_color.a == 1)
    #expect(info.load_op == SDL_GPU_LOADOP_CLEAR)
    #expect(info.store_op == SDL_GPU_STOREOP_STORE)
  }
}
