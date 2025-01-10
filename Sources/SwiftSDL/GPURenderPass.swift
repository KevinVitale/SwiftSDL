public protocol RenderPass: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: RenderPass { }

public func SDL_BeginGPURenderPass(
  commandBuffer: any CommandBuffer
  , colorTargetInfos: [SDL_GPUColorTargetInfo]
  , depthStencilTargetInfo: SDL_GPUDepthStencilTargetInfo? = nil
) throws(SDL_Error) -> some RenderPass {
  var depthStencilTargetInfo = depthStencilTargetInfo
  guard let pointer = SDL_BeginGPURenderPass(
    commandBuffer.pointer
    , colorTargetInfos.withUnsafeBufferPointer(\.baseAddress)
    , UInt32(colorTargetInfos.count)
    , depthStencilTargetInfo != nil ? .some(&depthStencilTargetInfo!) : nil
  ) else {
    throw .error
  }
  return SDLObject(pointer, tag: .custom("render pass"))
}

extension SDL_GPUColorTargetInfo {
  public init(
    texture: OpaquePointer
    , clearColor r: Float , g: Float, b: Float, a: Float = 1
    , load_op: SDL_GPULoadOp = SDL_GPU_LOADOP_CLEAR
    , store_op: SDL_GPUStoreOp = SDL_GPU_STOREOP_STORE
  ) {
    self = .init()
    self.texture = texture
    self.clear_color = SDL_FColor(r: r, g: g, b: b, a: a)
    self.load_op = load_op
    self.store_op = store_op
  }
}

extension SDL_GPUDepthStencilTargetInfo {
  public init(
  texture: OpaquePointer?
  , clearDepth: Float = 1
  , clearStencil: UInt32 = 0
  , load_op: SDL_GPULoadOp = SDL_GPU_LOADOP_CLEAR
  , store_op: SDL_GPUStoreOp = SDL_GPU_STOREOP_DONT_CARE
  , stencil_load_op: SDL_GPULoadOp = SDL_GPU_LOADOP_DONT_CARE
  , stencil_store_op: SDL_GPUStoreOp = SDL_GPU_STOREOP_DONT_CARE
  , cycle: Bool = false
  ) {
    self = .init()
    self.texture = texture
    self.load_op = load_op
    self.store_op = store_op
    self.stencil_load_op = stencil_load_op
    self.stencil_store_op = stencil_store_op
    self.cycle = cycle
  }
}
