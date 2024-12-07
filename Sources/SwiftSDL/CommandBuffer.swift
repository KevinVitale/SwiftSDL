public protocol CommandBuffer: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: CommandBuffer { }

extension CommandBuffer {
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

public protocol RenderPass: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: RenderPass { }


