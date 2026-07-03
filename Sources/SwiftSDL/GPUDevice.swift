/// SDL3 Documentation
/// https://wiki.libsdl.org/SDL3/CategoryGPU

// MARK: - Protocol
public protocol GPUDevice: SDLObjectProtocol, Sendable where Pointer == OpaquePointer { }

extension SDLObject<OpaquePointer>: GPUDevice { }

public func SDL_CreateGPUDevice(flags: SDL_GPUShaderFormat..., debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
  try SDL_CreateGPUDevice(flags: flags, debugMode: debugMode, named: driver)
}

public func SDL_CreateGPUDevice(claimFor window: (any Window)? = nil, flags: [SDL_GPUShaderFormat] = Array(SDL_GPUShaderFormat.allCases[1...]), debugMode: Bool = false, named driver: String? = nil) throws(SDL_Error) -> some GPUDevice {
  guard let pointer =
          SDL_CreateGPUDevice(
            flags.reduce(UInt32(0)) { $0 | UInt32($1.rawValue) }
            , debugMode
            , driver
          )
  else {
    throw .error
  }
  
  var deviceDriver = ""
  if let namePtr = SDL_GetGPUDeviceDriver(pointer) {
    deviceDriver = String(cString: namePtr)
  }
  
  let gpuDevice: SDLObject<OpaquePointer> = SDLObject(
    pointer
    , tag: .custom("gpu device (\(driver ?? deviceDriver))")
    , destroy: SDL_DestroyGPUDevice
  )
  
  if let windowPointer = window?.pointer {
    try gpuDevice(SDL_ClaimWindowForGPUDevice, windowPointer)
  }
  
  return gpuDevice
}

extension GPUDevice {
  public var deviceName: Result<String, SDL_Error> {
    self
      .resultOf(SDL_GetGPUDeviceDriver)
      .map(String.init(cString:))
  }
  
  public func acquireCommandBuffer() throws(SDL_Error) -> some CommandBuffer {
    try SDL_AcquireGPUCommandBuffer(with: self)
  }
  
  public func has(format: SDL_GPUShaderFormat) -> Bool {
    ((try? self(SDL_GetGPUShaderFormats) & format.rawValue) != 0)
  }
  
  public func release(shader: any GPUShader) throws(SDL_Error) {
    try self(SDL_ReleaseGPUShader, shader.pointer)
  }

  /// Creates a graphics pipeline, filling `createInfo.target_info` with the
  /// given color-target descriptions (and optional depth-stencil format).
  ///
  /// The descriptions pointer embedded in the create-info is scoped to the
  /// underlying C call — this is the only safe way to populate
  /// `target_info.color_target_descriptions`, which SDL reads at create time.
  public func createGraphicsPipeline(
    _ createInfo: SDL_GPUGraphicsPipelineCreateInfo
    , colorTargetDescriptions: [SDL_GPUColorTargetDescription]
    , depthStencilFormat: SDL_GPUTextureFormat? = nil
  ) throws(SDL_Error) -> OpaquePointer {
    var createInfo = createInfo
    let devicePointer = pointer
    let pipeline: OpaquePointer? = colorTargetDescriptions.withUnsafeBufferPointer { descriptions in
      createInfo.target_info.num_color_targets = UInt32(descriptions.count)
      createInfo.target_info.color_target_descriptions = descriptions.baseAddress
      if let depthStencilFormat {
        createInfo.target_info.has_depth_stencil_target = true
        createInfo.target_info.depth_stencil_format = depthStencilFormat
      }
      return withUnsafePointer(to: createInfo) {
        SDL_CreateGPUGraphicsPipeline(devicePointer, $0)
      }
    }
    guard let pipeline else {
      throw .error
    }
    return pipeline
  }
}
