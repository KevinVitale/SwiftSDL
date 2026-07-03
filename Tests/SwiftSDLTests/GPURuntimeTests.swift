import Testing
import SwiftSDL

/// GPU runtime tests run inside exit-test child processes.
///
/// The parent test process runs the "dummy" video driver, and SDL's Metal
/// GPU backend refuses to load without a Metal-capable video driver
/// (METAL_PrepareDriver checks Metal_CreateView; GPU backend selection
/// requires the live video device — SDL_gpu.c:603). Exit-test children are
/// fresh processes, so they initialize the real cocoa driver and exercise
/// the actual GPU path — still with no window.
@Suite struct GPURuntimeTests {
  /// GREEN pin — full offscreen render-pass round trip through the Swift
  /// wrappers: device → texture → acquire → begin (clear) → end → submit.
  /// Pins the SDL_BeginGPURenderPass wrapper across the pointer-scoping
  /// refactor (task 9).
  @Test func offscreenRenderPassRoundTrip() async {
    await #expect(processExitsWith: .success) {
      // Cocoa video init must happen on the child's main thread, or AppKit's
      // dispatch assertion traps.
      try await MainActor.run {
      try SDL_Init(.video)  // cocoa in the child — no dummy hint here

      let device = try SDL_CreateGPUDevice(claimFor: nil, debugMode: true)

      var textureInfo = SDL_GPUTextureCreateInfo()
      textureInfo.type = SDL_GPU_TEXTURETYPE_2D
      textureInfo.format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
      textureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET
      textureInfo.width = 64
      textureInfo.height = 64
      textureInfo.layer_count_or_depth = 1
      textureInfo.num_levels = 1
      textureInfo.sample_count = SDL_GPU_SAMPLECOUNT_1

      let texture = try device(SDL_CreateGPUTexture, .some(&textureInfo))
      defer { SDL_ReleaseGPUTexture(device.pointer, texture) }

      let commandBuffer = try device.acquireCommandBuffer()
      let renderPass = try SDL_BeginGPURenderPass(
        commandBuffer: commandBuffer,
        colorTargetInfos: [
          SDL_GPUColorTargetInfo(texture: texture, clearColor: 1, g: 0, b: 0)
        ],
        depthStencilTargetInfo: nil
      )
      try renderPass(SDL_EndGPURenderPass)
      try commandBuffer.submit()
      }
    }
  }
}
