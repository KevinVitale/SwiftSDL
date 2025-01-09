extension SDL.Test {
  final class SpinningCube: Game {
    enum CodingKeys: CodingKey {
      case options
      case msaa
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL gpu device routines using a spinning cube"
    )
    
    static let name: String = "SDL Test: Spinning Cube"
    
    @OptionGroup var options: Options
    
    @Flag var msaa: Bool = false
    
    private var gpuDevice: (any GPUDevice)! = nil
    private var resolveTexture: OpaquePointer? = nil
    private var depthTexture: OpaquePointer? = nil
    private var shader: OpaquePointer? = nil
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      self.gpuDevice = try SDL_CreateGPUDevice(claimFor: window)
      print("GPU Driver:", try gpuDevice.deviceName.get())
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
          
          return [
            ("Draw Cube", [colorTargetInfo], depthStencilTargetInfo: depthTargetInfo)
          ]
      }) { tag, pass in
        try pass(SDL_BindGPUGraphicsPipeline, nil)
        try pass(SDL_BindGPUVertexBuffers, 0, nil, 0)
        // try pass(SDL_DrawGPUPrimitives, 36, 1, 0, 0)
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
    
    func _loadShader(shader: Shader) throws(SDL_Error) -> OpaquePointer {
      var createinfo = SDL_GPUShaderCreateInfo();
      createinfo.num_samplers = 0;
      createinfo.num_storage_buffers = 0;
      createinfo.num_storage_textures = 0;
      createinfo.num_uniform_buffers = shader == .vertex ? 1 : 0;
      createinfo.props = 0;
      
      let format = try gpuDevice(SDL_GetGPUShaderFormats)
      if ((format & SDL_GPU_SHADERFORMAT_DXBC) != 0) {
        createinfo.format = SDL_GPU_SHADERFORMAT_DXBC;
        // createinfo.code = shader == .vertex ? D3D11_CubeVert : D3D11_CubeFrag
        // createinfo.code_size = shader == .vertex ? SDL_arraysize(D3D11_CubeVert) : SDL_arraysize(D3D11_CubeFrag)
        // createinfo.entrypoint = shader == .vertex ? "VSMain" : "PSMain"
      } else if ((format & SDL_GPU_SHADERFORMAT_DXIL) != 0) {
        createinfo.format = SDL_GPU_SHADERFORMAT_DXIL
        // createinfo.code = shader == .vertex ? D3D12_CubeVert : D3D12_CubeFrag
        // createinfo.code_size = shader == .vertex ? SDL_arraysize(D3D12_CubeVert) : SDL_arraysize(D3D12_CubeFrag)
        // createinfo.entrypoint = shader == .vertex ? "VSMain" : "PSMain"
      } else if ((format & SDL_GPU_SHADERFORMAT_METALLIB) != 0) {
        createinfo.format = SDL_GPU_SHADERFORMAT_METALLIB
        createinfo.code = shader == .vertex ? cube_vert_metallib.withUnsafeBufferPointer(\.baseAddress) : cube_frag_metallib.withUnsafeBufferPointer(\.baseAddress)
        createinfo.code_size = shader == .vertex ? cube_vert_metallib_len : cube_frag_metallib_len
        createinfo.entrypoint = shader == .vertex ? UnsafePointer("vs_main") : UnsafePointer("fs_main")
      } else {
        createinfo.format = SDL_GPU_SHADERFORMAT_SPIRV
        // createinfo.code = shader == .vertex ? cube_vert_spv : cube_frag_spv
        // createinfo.code_size = shader == .vertex ? cube_vert_spv_len : cube_frag_spv_len
        // createinfo.entrypoint = "main"
      }
      
      createinfo.stage = shader == .vertex ? SDL_GPU_SHADERSTAGE_VERTEX : SDL_GPU_SHADERSTAGE_FRAGMENT;
      return try gpuDevice(SDL_CreateGPUShader, .some(&createinfo))
    }
  }
}

extension SDL.Test.SpinningCube {
  enum Shader {
    case vertex
    case fragment
  }
}
