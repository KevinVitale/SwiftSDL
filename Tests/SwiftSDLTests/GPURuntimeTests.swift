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

  /// Contract pin — real graphics-pipeline creation through the
  /// pointer-scoped `createGraphicsPipeline` API (which replaced the
  /// pointer-storing SDL_GPUGraphicsPipelineTargetInfo init), using MSL
  /// shaders the Metal backend compiles from source.
  @Test func graphicsPipelineCreation() async {
    await #expect(processExitsWith: .success) {
      try await MainActor.run {
        try SDL_Init(.video)
        let device = try SDL_CreateGPUDevice(claimFor: nil, debugMode: true)

        func makeShader(entry: String, stage: SDL_GPUShaderStage) throws(SDL_Error) -> OpaquePointer {
          let source = """
          #include <metal_stdlib>
          using namespace metal;
          vertex float4 vmain(uint vid [[vertex_id]]) {
            float2 p = float2(float(vid == 1) * 4 - 1, float(vid == 2) * 4 - 1);
            return float4(p, 0, 1);
          }
          fragment float4 fmain() { return float4(1, 0, 0, 1); }
          """
          let code = Array(source.utf8)
          let entrypoint = Array(entry.utf8CString)
          let shader: OpaquePointer? = code.withUnsafeBufferPointer { codeBuffer in
            entrypoint.withUnsafeBufferPointer { entryBuffer in
              var info = SDL_GPUShaderCreateInfo()
              info.code = codeBuffer.baseAddress
              info.code_size = codeBuffer.count
              info.entrypoint = entryBuffer.baseAddress
              info.format = UInt32(SDL_GPU_SHADERFORMAT_MSL)
              info.stage = stage
              return withUnsafePointer(to: info) { SDL_CreateGPUShader(device.pointer, $0) }
            }
          }
          guard let shader else { throw .error }
          return shader
        }

        let vertex = try makeShader(entry: "vmain", stage: SDL_GPU_SHADERSTAGE_VERTEX)
        let fragment = try makeShader(entry: "fmain", stage: SDL_GPU_SHADERSTAGE_FRAGMENT)
        defer {
          SDL_ReleaseGPUShader(device.pointer, vertex)
          SDL_ReleaseGPUShader(device.pointer, fragment)
        }

        let createInfo = SDL_GPUGraphicsPipelineCreateInfo(
          vertexShader: SDLObject(vertex) as (any GPUShader),
          fragmentShader: SDLObject(fragment) as (any GPUShader),
          primitiveType: .triangleList,
          rasterizerState: .init(fillMode: SDL_GPU_FILLMODE_FILL)
        )
        let pipeline = try device.createGraphicsPipeline(
          createInfo,
          colorTargetDescriptions: [
            SDL_GPUColorTargetDescription(format: SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM)
          ]
        )
        SDL_ReleaseGPUGraphicsPipeline(device.pointer, pipeline)
      }
    }
  }
}
