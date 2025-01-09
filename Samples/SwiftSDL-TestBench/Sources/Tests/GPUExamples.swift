extension SDL.Test {
  final class GPUExamples: Game {
    enum CodingKeys: CodingKey {
      case options
      case msaa
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Re-implementation of some TheSpydog/SDL_gpu_examples using SwiftSDL"
    )
    
    static let name: String = "SDL Test: GPU Examples"
    
    @OptionGroup var options: Options
    
    @Flag var msaa: Bool = false
    
    private var gpuDevice: (any GPUDevice)! = nil
    private var resolveTexture: OpaquePointer? = nil
    private var depthTexture: OpaquePointer? = nil
    private var fillPipeline: OpaquePointer? = nil
    private var linePipeline: OpaquePointer? = nil
    
    private var smallViewport: SDL_GPUViewport = .init(x: 160, y: 120, w: 320, h: 240, min_depth: 0.1, max_depth: 1.0)
    private var scissorRect: SDL_Rect = [ 320, 240, 320, 240 ];
    private var useWireframe: Bool = false
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      SDL_SetHint(SDL_HINT_RENDER_GPU_DEBUG, "1")
      self.gpuDevice = try SDL_CreateGPUDevice(claimFor: window)
      print("GPU Driver:", try gpuDevice.deviceName.get())
      
      let vertShader = try Load(shader: "RawTriangle.vert", device: gpuDevice)
      let fragShader = try Load(shader: "SolidColor.frag", device: gpuDevice)
      
      // Create the pipelines
      var colorTargetInfo = SDL_GPUColorTargetDescription()
      colorTargetInfo.format = try gpuDevice(SDL_GetGPUSwapchainTextureFormat, window.pointer)
      
      let colorTargetDesc: [SDL_GPUColorTargetDescription] = [colorTargetInfo]
      
      var pipeline = SDL_GPUGraphicsPipelineCreateInfo()
      pipeline.target_info.num_color_targets = 1
      pipeline.target_info.color_target_descriptions = colorTargetDesc.withUnsafeBufferPointer(\.baseAddress)
      pipeline.vertex_shader   = vertShader.pointer
      pipeline.fragment_shader = fragShader.pointer
      pipeline.primitive_type  = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
      pipeline.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_FILL
      
      fillPipeline = try gpuDevice(SDL_CreateGPUGraphicsPipeline, .some(&pipeline))
      
      pipeline.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_LINE
      linePipeline = try gpuDevice(SDL_CreateGPUGraphicsPipeline, .some(&pipeline))
    }
    
    func onUpdate(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      let matrix = Array(repeating: Float.zero, count: 16)
      
      let cmdBuf = try gpuDevice.acquireCommandBuffer()
      try cmdBuf(SDL_PushGPUVertexUniformData, 0, matrix.withUnsafeBytes(\.baseAddress), UInt32(matrix.count))
      try cmdBuf.render(to: window, passes: { swapchain, size in
        if depthTexture == nil {
          depthTexture = try _createDepthTexture(gpuDevice: gpuDevice, size: size)
        }
        
        let colorTargetInfo = SDL_GPUColorTargetInfo(
          texture: swapchain,
          clearColor: 0.3, g: 0.4, b: 0.5
        )
        
        let depthTargetInfo = SDL_GPUDepthStencilTargetInfo(
          texture: depthTexture,
          cycle: true
        )
        
        smallViewport.w = Float(size.x)
        smallViewport.h = Float(size.y)
        smallViewport.x = 0
        smallViewport.y = 0

        return [
          ("Draw Cube", [colorTargetInfo], depthStencilTargetInfo: depthTargetInfo)
        ]
      }) { tag, pass in
        try pass(SDL_BindGPUGraphicsPipeline, fillPipeline)
        try pass(SDL_SetGPUViewport, .some(&smallViewport))
        try pass(SDL_DrawGPUPrimitives, 3, 1, 0, 0)
      }.submit()
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      try gpuDevice?(SDL_ReleaseGPUTexture, resolveTexture)
      try gpuDevice?(SDL_ReleaseGPUTexture, depthTexture)
      gpuDevice = nil
    }
    
    private func _createDepthTexture(gpuDevice: any GPUDevice, size: Size<UInt32>) throws(SDL_Error) -> OpaquePointer {
      var createInfo = SDL_GPUTextureCreateInfo()
      createInfo.type = SDL_GPU_TEXTURETYPE_2D
      createInfo.format = SDL_GPU_TEXTUREFORMAT_D16_UNORM
      createInfo.width = size.x
      createInfo.height = size.y
      createInfo.layer_count_or_depth = 1
      createInfo.num_levels = 1
      createInfo.sample_count = SDL_GPU_SAMPLECOUNT_1
      createInfo.usage = SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET
      createInfo.props = 0
      
      return try gpuDevice(SDL_CreateGPUTexture, .some(&createInfo))
    }
  }
}

extension SDL.Test.GPUExamples {
  enum Shader {
    case vertex
    case fragment
  }
}
