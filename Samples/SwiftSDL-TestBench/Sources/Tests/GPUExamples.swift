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
    
    fileprivate weak var window: (any Window)! = nil
    fileprivate var gpuDevice: (any GPUDevice)! = nil
    
    private var examples: [Example] = [
      ClearScreen(),
      BasicTriangle(),
      BasicVertexBuffer()
    ]
    
    func onReady(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      SDL_SetHint(SDL_HINT_RENDER_GPU_DEBUG, "1")
      
      self.window = window
      self.gpuDevice = try window.createGPUDevice(with: [.msl])
      print("GPU Driver:", try gpuDevice.deviceName.get())
      
      let example = examples.first!
      try example.`init`(self)
    }
    
    func onUpdate(window: any SwiftSDL.Window) throws(SwiftSDL.SDL_Error) {
      let example = examples.first!
      try example.update(self)
      try example.draw(self)
    }
    
    func onEvent(window: any SwiftSDL.Window, _ event: SDL_Event) throws(SwiftSDL.SDL_Error) {
    }
    
    func onShutdown(window: (any SwiftSDL.Window)?) throws(SwiftSDL.SDL_Error) {
      gpuDevice = nil
    }
    
  }
}

fileprivate protocol Example: AnyObject {
  func `init`(_ context: SDL.Test.GPUExamples) throws(SDL_Error)
  func update(_ context: SDL.Test.GPUExamples) throws(SDL_Error)
  func draw(_ context: SDL.Test.GPUExamples) throws(SDL_Error)
  func quit(_ context: SDL.Test.GPUExamples) throws(SDL_Error)
}

extension SDL.Test.GPUExamples {
  final class ClearScreen: Example {
    func `init`(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
    func update(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
    func draw(_ context: SDL.Test.GPUExamples) throws(SDL_Error) {
      let gpuDevice = context.gpuDevice!
      let window = context.window!
      
      try gpuDevice
        .acquireCommandBuffer()
        .render(to: window, passes: { swapchain, size in
          [
            ("Clear Screen", [
              SDL_GPUColorTargetInfo(
                texture: swapchain,
                clearColor: 0.3, g: 0.4, b: 0.5
              )
            ], depthStencilTargetInfo: nil)
          ]
        })
        .submit()
    }
    func quit(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
  }
}

extension SDL.Test.GPUExamples {
  final class BasicVertexBuffer: Example {
    func `init`(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
    func update(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
    func draw(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
    func quit(_ context: SDL.Test.GPUExamples) throws(SDL_Error) { }
  }
}

extension SDL.Test.GPUExamples {
  final class BasicTriangle: Example {
    private var fillPipeline: OpaquePointer? = nil
    private var linePipeline: OpaquePointer? = nil
    private var smallViewport: SDL_GPUViewport = .init(
      x: 160,
      y: 120,
      w: 320,
      h: 240,
      min_depth: 0.1,
      max_depth: 1.0
    )
    
    func `init`(_ context: SDL.Test.GPUExamples) throws(SDL_Error) {
      let gpuDevice = context.gpuDevice!
      let window = context.window!
      
      let vertShader = try Load(shader: "RawTriangle.vert", device: gpuDevice)
      let fragShader = try Load(shader: "SolidColor.frag", device: gpuDevice)
      
      var colorTargets: [SDL_GPUColorTargetDescription] = [
        SDL_GPUColorTargetDescription(format: try gpuDevice(SDL_GetGPUSwapchainTextureFormat, window.pointer))
      ]

      var pipeline = SDL_GPUGraphicsPipelineCreateInfo(
        vertexShader: vertShader
        , fragmentShader: fragShader
        , primitiveType: .triangleList
        , rasterizerState: .init(fillMode: SDL_GPU_FILLMODE_FILL)
        , targetInfo: .init(colorTargetDescriptions: &colorTargets)
      )
      
      self.fillPipeline = try gpuDevice(SDL_CreateGPUGraphicsPipeline, .some(&pipeline))
      
      pipeline.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_LINE
      self.linePipeline = try gpuDevice(SDL_CreateGPUGraphicsPipeline, .some(&pipeline))
    }
    
    func update(_ context: SDL.Test.GPUExamples) throws(SDL_Error) {
    }
    
    func draw(_ context: SDL.Test.GPUExamples) throws(SDL_Error) {
      let gpuDevice = context.gpuDevice!
      let window = context.window!
      
      try gpuDevice
        .acquireCommandBuffer()
        .render(to: window, passes: { swapchain, size in
          let colorTargetInfo = SDL_GPUColorTargetInfo(
            texture: swapchain,
            clearColor: 0, g: 0, b: 0
          )
          
          self.smallViewport.w = Float(size.x)
          self.smallViewport.h = Float(size.y)
          self.smallViewport.x = 0
          self.smallViewport.y = 0
          
          return [
            ("Draw Cube", [colorTargetInfo], depthStencilTargetInfo: nil)
          ]
        }) { tag, pass in
          try pass(SDL_BindGPUGraphicsPipeline, fillPipeline)
          try pass(SDL_SetGPUViewport, .some(&smallViewport))
          try pass(SDL_DrawGPUPrimitives, 3, 1, 0, 0)
        }
        .submit()
    }
    
    func quit(_ context: SDL.Test.GPUExamples) throws(SDL_Error) {
    }
  }
}
