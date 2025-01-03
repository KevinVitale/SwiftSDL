public protocol CommandBuffer: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: CommandBuffer { }

func SDL_AcquireGPUCommandBuffer(with gpuDevice: any GPUDevice) throws(SDL_Error) -> some CommandBuffer {
  guard let pointer = SDL_AcquireGPUCommandBuffer(gpuDevice.pointer) else {
    throw .error
  }
  return SDLObject<OpaquePointer>(pointer, tag: .custom("command buffer"))
}

extension CommandBuffer {
  public typealias SwapchainRenderPassTuple =
  (String, ColorTargetInfos: [SDL_GPUColorTargetInfo], depthStencilTargetInfo:  SDL_GPUDepthStencilTargetInfo?)
  
  public typealias SwapchainRenderPassCallback = (_ swapchain: OpaquePointer) throws -> [SwapchainRenderPassTuple]
  
  @discardableResult
  public func render(
    to window: any Window
    , passes: SwapchainRenderPassCallback
    , bindAndDraw: ((_ tag: String, _ renderPass: any RenderPass) throws -> Void) = { _, _ in }
  ) throws(SDL_Error) -> Self {
    var swapchainTexture: OpaquePointer! = nil
    try self(
      SDL_AcquireGPUSwapchainTexture
      , window.pointer
      , .some(&swapchainTexture)
      , nil
      , nil
    )
    
    do {
      for (tag, colorTargetInfos, depthStencilTargetInfo) in try passes(swapchainTexture) {
        let renderPass = try SDL_BeginGPURenderPass(
          commandBuffer: self,
          colorTargetInfos: colorTargetInfos,
          depthStencilTargetInfo: depthStencilTargetInfo
        )
        try bindAndDraw(tag, renderPass)
        try renderPass(SDL_EndGPURenderPass)
      }
    }
    catch {
      throw error as! SDL_Error
    }
    
    return self
  }
  
  @discardableResult
  public func submit() throws(SDL_Error) -> Self {
    try self(SDL_SubmitGPUCommandBuffer)
  }
}
