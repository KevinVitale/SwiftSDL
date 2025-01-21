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

extension SDL_GPUGraphicsPipelineCreateInfo {
  public init(
  vertexShader: (any GPUShader)? = nil
  , fragmentShader: (any GPUShader)? = nil
  , vertexInputState: SDL_GPUVertexInputState? = nil
  , primitiveType: SDL_GPUPrimitiveType
  , rasterizerState: SDL_GPURasterizerState? = nil
  , targetInfo: SDL_GPUGraphicsPipelineTargetInfo? = nil
  , depthStencilState: SDL_GPUDepthStencilState? = nil
  ) {
    self = .init()
    self.vertex_shader = vertexShader?.pointer
    self.fragment_shader = fragmentShader?.pointer
    self.vertex_input_state = vertexInputState ?? .init()
    self.primitive_type = primitiveType
    self.rasterizer_state = rasterizerState ?? .init()
    self.target_info = targetInfo ?? .init()
    self.depth_stencil_state = depthStencilState ?? .init()
  }
}

extension SDL_GPUGraphicsPipelineTargetInfo {
  public init(
    colorTargetDescriptions: inout [SDL_GPUColorTargetDescription]
    , depthStencilFormat: SDL_GPUTextureFormat? = nil
  ) {
    self = .init()
    if let depthStencilFormat = depthStencilFormat {
      self.has_depth_stencil_target = true
      self.depth_stencil_format = depthStencilFormat
    }
    self.num_color_targets = UInt32(colorTargetDescriptions.count)
    self.color_target_descriptions = colorTargetDescriptions.withUnsafeBufferPointer(\.baseAddress)
  }
}

extension SDL_GPUDepthStencilState {
  public init(
    enableDepthTest: Bool = false
    , enableDepthWrite: Bool = false
    , enableStencilTest: Bool = false
    , compareOp: SDL_GPUCompareOp = SDL_GPU_COMPAREOP_LESS
    , writeMask: UInt8
  ) {
    self = .init()
    self.enable_depth_test = enableDepthTest
    self.enable_depth_write = enableDepthWrite
    self.enable_stencil_test = enableStencilTest
    self.compare_op = compareOp
  }
}

extension SDL_GPURasterizerState {
  public init(
    fillMode: SDL_GPUFillMode
  ) {
    self = .init()
    self.fill_mode = fillMode
  }
}

extension SDL_GPUColorTargetDescription {
  public init(
    format: SDL_GPUTextureFormat,
    blendState: SDL_GPUColorTargetBlendState? = nil
  ) {
    self = .init()
    self.format = format
    self.blend_state = blendState ?? .init()
  }
}

extension SDL_GPUPrimitiveType: @retroactive CaseIterable, @retroactive CustomDebugStringConvertible {
  public static let triangleList = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
  public static let triangleStrip = SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP
  public static let lineList = SDL_GPU_PRIMITIVETYPE_LINELIST
  public static let lineStrip = SDL_GPU_PRIMITIVETYPE_LINESTRIP
  public static let pointList = SDL_GPU_PRIMITIVETYPE_POINTLIST
  
  public var debugDescription: String {
    switch self {
      case .triangleList: return "triangle list"
      case .triangleStrip: return "triangle strip"
      case .lineList: return "line list"
      case .lineStrip: return "line strip"
      case .pointList: return "point list"
      default: return "Unknown SDL_GPUPrimitiveType: \(self)"
    }
  }
  
  public static var allCases: [SDL_GPUPrimitiveType] {
    [.triangleList, .triangleStrip, .lineList, .lineStrip, .pointList]
  }
}
