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
  (ColorTargetInfos: [SDL_GPUColorTargetInfo], depthStencilTargetInfo:  SDL_GPUDepthStencilTargetInfo?)
  
  public typealias SwapchainRenderPassCallback = (_ swapchain: OpaquePointer) throws -> [SwapchainRenderPassTuple]
  
  @discardableResult
  public func render(to window: any Window, passes: SwapchainRenderPassCallback) throws(SDL_Error) -> Self {
    var swapchainTexture: OpaquePointer! = nil
    try self(
      SDL_AcquireGPUSwapchainTexture
      , window.pointer
      , .some(&swapchainTexture)
      , nil
      , nil
    )
    
    do {
      for (colorTargetInfos, depthStencilTargetInfo) in try passes(swapchainTexture) {
        let renderPass = try SDL_BeginGPURenderPass(
          commandBuffer: self,
          colorTargetInfos: colorTargetInfos,
          depthStencilTargetInfo: depthStencilTargetInfo
        )
        try renderPass(SDL_EndGPURenderPass)
      }
    }
    catch {
      throw error as! SDL_Error
    }
    
    return self
  }
  
  @discardableResult
  public func render(colorTargetInfos: SDL_GPUColorTargetInfo..., depthStencilTargetInfo: SDL_GPUDepthStencilTargetInfo? = nil, _ pass: (any RenderPass) throws -> Void) throws(SDL_Error) -> Self {
    try self.render(
      colorTargetInfos: colorTargetInfos
      , depthStencilTargetInfo: depthStencilTargetInfo
      , pass
    )
  }
  
  @discardableResult
  public func submit() throws(SDL_Error) -> Self {
    try self(SDL_SubmitGPUCommandBuffer)
  }
  
  public func render(
    colorTargetInfos: [SDL_GPUColorTargetInfo]
    , depthStencilTargetInfo: SDL_GPUDepthStencilTargetInfo? = nil
    , _ pass: (any RenderPass) throws -> Void)
  throws(SDL_Error) -> Self {
    let colorTargetInfos = colorTargetInfos
    var depthStencilTargetInfo = depthStencilTargetInfo
    
    let pointer = try self(
      SDL_BeginGPURenderPass
      , colorTargetInfos.withUnsafeBufferPointer(\.baseAddress)
      , UInt32(colorTargetInfos.count)
      , depthStencilTargetInfo != nil ? .some(&depthStencilTargetInfo!) : nil
    )
    
    let renderPass = SDLObject<OpaquePointer>(
      pointer
      , tag: .custom("render pass")
      , destroy: SDL_EndGPURenderPass
    )
    
    do { try pass(renderPass) }
    catch { throw error as! SDL_Error }
    
    return self
  }
}
